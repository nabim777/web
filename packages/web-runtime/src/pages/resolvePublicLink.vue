<template>
  <div
    class="oc-link-resolve oc-height-viewport oc-flex oc-flex-column oc-flex-center oc-flex-middle"
  >
    <div class="oc-card oc-text-center oc-width-large">
      <template v-if="isLoading">
        <div class="oc-card-header">
          <h2 key="public-link-loading">
            <span v-text="$gettext('Loading public link…')" />
          </h2>
        </div>
        <div class="oc-card-body">
          <oc-spinner :aria-hidden="true" />
        </div>
      </template>
      <template v-else-if="errorMessage">
        <div class="oc-card-header oc-link-resolve-error-title">
          <h2 key="public-link-error">
            <span v-text="$gettext('An error occurred while loading the public link')" />
          </h2>
        </div>
        <div class="oc-card-body oc-link-resolve-error-message">
          <p class="oc-text-xlarge">{{ errorMessage }}</p>
        </div>
      </template>
      <template v-else-if="isPasswordRequired">
        <form @submit.prevent="resolvePublicLinkTask.perform(true)">
          <div class="oc-card-header">
            <h2>
              <span v-text="$gettext('This resource is password-protected')" />
            </h2>
          </div>
          <div class="oc-card-body">
            <oc-text-input
              ref="passwordInput"
              v-model="password"
              :error-message="wrongPasswordMessage"
              :label="passwordFieldLabel"
              type="password"
              class="oc-mb-s"
            />
            <oc-button
              variation="primary"
              appearance="filled"
              class="oc-login-authorize-button"
              :disabled="!password"
              submit="submit"
            >
              <span v-text="$gettext('Continue')" />
            </oc-button>
          </div>
        </form>
      </template>
      <div class="oc-card-footer oc-pt-rm">
        <p>{{ footerSlogan }}</p>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { SharePermissionBit } from 'web-client/src/helpers/share'
import { authService } from '../services/auth'

import {
  queryItemAsString,
  useCapabilitySpacesEnabled,
  useClientService,
  useConfigurationManager,
  useRouteParam,
  useRouteQuery,
  useRouter,
  useStore,
  useUserContext
} from 'web-pkg/src/composables'
import { useTask } from 'vue-concurrency'
import { ref, unref, computed, defineComponent, onMounted } from 'vue'
import {
  buildWebDavPublicPath,
  buildPublicSpaceResource,
  isPublicSpaceResource,
  PublicSpaceResource
} from 'web-client/src/helpers'
import isEmpty from 'lodash-es/isEmpty'
import { useGettext } from 'vue3-gettext'
// full import is needed here so it can be overwritten via CERN config
import { useLoadTokenInfo } from 'web-runtime/src/composables/tokenInfo'

export default defineComponent({
  name: 'ResolvePublicLink',
  setup() {
    const configurationManager = useConfigurationManager()
    const clientService = useClientService()
    const router = useRouter()
    const store = useStore()
    const { $gettext } = useGettext()
    const token = useRouteParam('token')
    const redirectUrl = useRouteQuery('redirectUrl')
    const password = ref('')
    const publicLinkSpace = computed(() =>
      buildPublicSpaceResource({
        id: unref(token),
        driveAlias: `public/${unref(token)}`,
        driveType: 'public',
        webDavPath: buildWebDavPublicPath(unref(token), ''),
        ...(unref(password) && { publicLinkPassword: unref(password) })
      })
    )
    const isUserContext = useUserContext({ store })
    const hasSpaces = useCapabilitySpacesEnabled(store)

    const detailsQuery = useRouteQuery('details')
    const details = computed(() => {
      return queryItemAsString(unref(detailsQuery))
    })

    // token info
    const { loadTokenInfoTask } = useLoadTokenInfo({ clientService, isUserContext })
    const tokenInfo = ref(null)

    // generic public link loading
    const isPasswordRequired = ref<boolean>()
    const isPasswordRequiredTask = useTask(function* () {
      if (!isEmpty(unref(tokenInfo))) {
        return unref(tokenInfo).password_protected
      }
      try {
        let space: PublicSpaceResource = {
          ...unref(publicLinkSpace),
          publicLinkPassword: null
        }
        yield clientService.webdav.getFileInfo(space)
        return false
      } catch (error) {
        if (error.statusCode === 401) {
          return true
        }
        if (error.statusCode === 404) {
          throw new Error($gettext('The resource could not be located, it may not exist anymore.'))
        }
        throw error
      }
    })
    const loadPublicLinkTask = useTask(function* () {
      try {
        const resource = yield clientService.webdav.getFileInfo(unref(publicLinkSpace))
        if (!isPublicSpaceResource(resource)) {
          const e: any = new Error($gettext('The resource is not a public link.'))
          e.resource = resource
          throw e
        }
        return resource
      } catch (e) {
        if (e.statusCode === 401) {
          throw e
        }
        throw new Error($gettext('The resource could not be located, it may not exist anymore.'))
      }
    })
    const wrongPassword = computed(() => {
      if (loadPublicLinkTask.isError) {
        return loadPublicLinkTask.last.error.statusCode === 401
      }
      return false
    })

    // resolve public link. resolve into authenticated context if possible.
    const redirectToPrivateLink = (fileId: string | number) => {
      return router.push({
        name: 'resolvePrivateLink',
        params: { fileId: `${fileId}` },
        ...(unref(details) && {
          query: {
            details: unref(details)
          }
        })
      })
    }
    const resolvePublicLinkTask = useTask(function* (signal, passwordRequired: boolean) {
      if (!isEmpty(unref(tokenInfo)) && unref(tokenInfo)?.alias_link) {
        redirectToPrivateLink(unref(tokenInfo).id)
        return
      }

      const publicLink = yield loadPublicLinkTask.perform()
      if (loadPublicLinkTask.isError) {
        const e = loadPublicLinkTask.last.error
        console.error(e, e.resource)
        return
      }

      yield authService.resolvePublicLink(
        unref(token),
        unref(passwordRequired),
        unref(passwordRequired) ? unref(password) : ''
      )

      const url = queryItemAsString(unref(redirectUrl))
      if (url) {
        router.push({ path: url })
        return
      }

      let { fileId } = publicLink
      if (!fileId && unref(hasSpaces)) {
        const { children } = yield clientService.webdav.listFiles(unref(publicLinkSpace), {
          path: '/'
        })
        if (children.length === 1) {
          // single shared file which means the actual resource is the first and only child element
          fileId = children[0].fileId
        }
      }

      if (publicLink.publicLinkPermission === SharePermissionBit.Create) {
        router.push({
          name: 'files-public-upload',
          params: { token: unref(token) },
          query: { ...(!!fileId && { fileId }) }
        })
        return
      }

      router.push({
        name: 'files-public-link',
        query: {
          ...(configurationManager.options.openLinksWithDefaultApp && {
            openWithDefaultApp: 'true'
          }),
          ...(!!fileId && { fileId })
        },
        params: { driveAliasAndItem: `public/${unref(token)}` }
      })
    })

    const isLoading = computed<boolean>(() => {
      if (unref(errorMessage)) {
        return false
      }
      if (
        loadTokenInfoTask.isRunning ||
        !loadTokenInfoTask.last ||
        isPasswordRequiredTask.isRunning ||
        !isPasswordRequiredTask.last
      ) {
        return true
      }
      if (!unref(isPasswordRequired)) {
        return resolvePublicLinkTask.isRunning || !resolvePublicLinkTask.last
      }
      return false
    })
    const errorMessage = computed<string>(() => {
      if (resolvePublicLinkTask.isError && resolvePublicLinkTask.last.error.statusCode !== 401) {
        return resolvePublicLinkTask.last.error.message
      }
      if (loadTokenInfoTask.isError) {
        return loadTokenInfoTask.last.error.message
      }
      if (isPasswordRequiredTask.isError) {
        return isPasswordRequiredTask.last.error.message
      }
      return null
    })

    onMounted(async () => {
      tokenInfo.value = await loadTokenInfoTask.perform(unref(token))
      isPasswordRequired.value = await isPasswordRequiredTask.perform()
      if (!unref(isPasswordRequired)) {
        await resolvePublicLinkTask.perform(false)
      }
    })

    const footerSlogan = computed(() => store.getters.configuration.currentTheme.general.slogan)
    const passwordFieldLabel = computed(() => {
      return $gettext('Enter password for public link')
    })
    const wrongPasswordMessage = computed(() => {
      if (unref(wrongPassword)) {
        return $gettext('Incorrect password')
      }
      return null
    })

    return {
      token,
      isPasswordRequired,
      password,
      wrongPassword,
      passwordFieldLabel,
      wrongPasswordMessage,
      isLoading,
      errorMessage,
      footerSlogan,
      loadTokenInfoTask,
      resolvePublicLinkTask,
      isPasswordRequiredTask
    }
  }
})
</script>

<style lang="scss">
.oc-link-resolve {
  .oc-card {
    background: var(--oc-color-background-highlight);
    border-radius: 15px;
  }

  .oc-text-input-message {
    justify-content: center;
  }

  .oc-card-header h2,
  .oc-card-footer p {
    margin: 0;
  }
}
</style>
