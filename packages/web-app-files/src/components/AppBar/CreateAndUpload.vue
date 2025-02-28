<template>
  <div v-if="showActions" class="create-and-upload-actions oc-flex-inline oc-mr-s">
    <template v-if="createFileActionsAvailable">
      <span v-oc-tooltip="newButtonTooltip">
        <oc-button
          id="new-file-menu-btn"
          key="new-file-menu-btn-enabled"
          v-oc-tooltip="hideButtonLabels ? $gettext('New') : ''"
          :aria-label="newButtonAriaLabel"
          appearance="filled"
          variation="primary"
          :disabled="uploadOrFileCreationBlocked"
        >
          <oc-icon name="add" />
          <span v-if="!hideButtonLabels" v-text="$gettext('New')" />
        </oc-button>
      </span>
      <oc-drop
        drop-id="new-file-menu-drop"
        toggle="#new-file-menu-btn"
        mode="click"
        close-on-click
        class="oc-width-auto"
        padding-size="small"
      >
        <oc-list id="create-list">
          <li class="create-list-folder oc-menu-item-hover">
            <oc-button id="new-folder-btn" appearance="raw" @click="createNewFolderAction">
              <oc-resource-icon :resource="folderIconResource" size="medium" />
              <span v-text="$gettext('Folder')" />
            </oc-button>
          </li>
          <li
            v-for="(fileAction, key) in createNewFileActions"
            :key="`file-creation-item-${key}`"
            class="create-list-file oc-menu-item-hover"
          >
            <oc-button
              appearance="raw"
              :class="['new-file-btn-' + fileAction.ext]"
              @click="fileAction.handler"
            >
              <oc-resource-icon :resource="getIconResource(fileAction)" size="medium" />
              <span>{{ fileAction.label() }}</span>
            </oc-button>
          </li>
          <template v-if="mimetypesAllowedForCreation">
            <li
              v-for="(mimeTypeAction, key) in createNewFileMimeTypeActions"
              :key="`file-creation-item-external-${key}`"
              class="create-list-file oc-menu-item-hover"
            >
              <oc-button appearance="raw" @click="mimeTypeAction.handler">
                <oc-resource-icon :resource="getIconResource(mimeTypeAction)" size="medium" />
                <span v-text="$gettext(mimeTypeAction.label())" />
              </oc-button>
            </li>
          </template>
        </oc-list>
      </oc-drop>
    </template>
    <template v-else>
      <span v-oc-tooltip="newButtonTooltip">
        <oc-button
          id="new-folder-btn"
          v-oc-tooltip="hideButtonLabels ? $gettext('New Folder') : ''"
          appearance="filled"
          variation="primary"
          :aria-label="newButtonAriaLabel"
          :disabled="uploadOrFileCreationBlocked"
          @click="createNewFolderAction"
        >
          <oc-icon name="resource-type-folder" />
          <span v-if="!hideButtonLabels" v-text="$gettext('New Folder')" />
        </oc-button>
      </span>
    </template>
    <span v-oc-tooltip="uploadButtonTooltip">
      <oc-button
        id="upload-menu-btn"
        key="upload-menu-btn-enabled"
        v-oc-tooltip="hideButtonLabels ? $gettext('Upload') : ''"
        :aria-label="uploadButtonAriaLabel"
        :disabled="uploadOrFileCreationBlocked"
        appearance="outline"
        variation="passive"
      >
        <oc-icon name="upload" fill-type="line" />
        <span v-if="!hideButtonLabels" v-text="$gettext('Upload')" />
      </oc-button>
    </span>
    <oc-drop
      drop-id="upload-menu-drop"
      toggle="#upload-menu-btn"
      mode="click"
      class="oc-width-auto"
      close-on-click
      padding-size="small"
      @show-drop="showDrop"
    >
      <oc-list id="upload-list" :class="{ 'oc-pb-s': extensionActions.length }">
        <li class="oc-menu-item-hover">
          <resource-upload ref="folder-upload" btn-class="oc-width-1-1" />
        </li>
        <li class="oc-menu-item-hover">
          <resource-upload ref="file-upload" btn-class="oc-width-1-1" :is-folder="true" />
        </li>
      </oc-list>
      <oc-list v-if="extensionActions.length" id="extension-list" class="oc-pt-s">
        <li
          v-for="(action, key) in extensionActions"
          :key="`${key}-${actionKeySuffix}`"
          v-oc-tooltip="
            isActionDisabled(action) && action.disabledTooltip ? action.disabledTooltip() : null
          "
          class="oc-menu-item-hover"
        >
          <oc-button
            class="oc-width-1-1"
            :class="action.class"
            appearance="raw"
            justify-content="left"
            :disabled="isActionDisabled(action)"
            @click="action.handler"
          >
            <oc-icon :name="action.icon" fill-type="line" /><span v-text="action.label()"
          /></oc-button>
        </li>
      </oc-list>
    </oc-drop>
    <div
      v-if="showPasteHereButton"
      id="clipboard-btns"
      v-oc-tooltip="
        uploadOrFileCreationBlocked ? $gettext('You have no permission to paste files here!') : ''
      "
      class="oc-button-group"
      :class="{ disabled: uploadOrFileCreationBlocked }"
    >
      <oc-button
        :disabled="uploadOrFileCreationBlocked"
        class="paste-files-btn"
        @click="pasteFileAction({ space })"
      >
        <oc-icon fill-type="line" name="clipboard" />
        <span v-text="$gettext('Paste here')" />
      </oc-button>
      <oc-button
        :disabled="uploadOrFileCreationBlocked"
        class="clear-clipboard-btn"
        @click="clearClipboardFiles"
      >
        <oc-icon fill-type="line" name="close" />
      </oc-button>
    </div>
  </div>
</template>

<script lang="ts">
import { mapActions, mapGetters } from 'vuex'

import { useFileActions } from '../../composables/actions/files/useFileActions'
import { isLocationPublicActive, isLocationSpacesActive } from '../../router'
import {
  useActiveLocation,
  useFileActionsCreateNewFile,
  useFileActionsCreateNewFolder,
  useFileActionsPaste
} from '../../composables'

import {
  useRequest,
  useCapabilityShareJailEnabled,
  useCapabilitySpacesEnabled,
  useStore,
  useUserContext,
  useClientService
} from 'web-pkg/src/composables'

import ResourceUpload from './Upload/ResourceUpload.vue'
import {
  computed,
  defineComponent,
  onMounted,
  onBeforeUnmount,
  PropType,
  unref,
  watch,
  ref
} from 'vue'
import { useUpload } from 'web-runtime/src/composables/upload'
import { eventBus } from 'web-pkg/src/services/eventBus'
import { Resource, SpaceResource, isShareSpaceResource } from 'web-client/src/helpers'
import { useService } from 'web-pkg/src/composables/service'
import { UppyService } from 'web-runtime/src/services/uppyService'
import { HandleUpload } from 'web-app-files/src/HandleUpload'
import { useRoute } from 'vue-router'
import { useGettext } from 'vue3-gettext'
import { ActionExtension, useExtensionRegistry } from 'web-pkg/src/composables/piniaStores'
import { Action } from 'web-pkg/src/composables/actions'
import { v4 as uuidv4 } from 'uuid'

export default defineComponent({
  components: {
    ResourceUpload
  },
  props: {
    space: {
      type: Object as PropType<SpaceResource>,
      required: true
    },
    item: {
      type: String,
      required: false,
      default: null
    },
    limitedScreenSpace: {
      type: Boolean,
      default: false,
      required: false
    },
    itemId: {
      type: [String, Number],
      required: false,
      default: null
    }
  },
  setup(props) {
    const uppyService = useService<UppyService>('$uppyService')
    const clientService = useClientService()
    const store = useStore()
    const route = useRoute()
    const language = useGettext()
    const hasSpaces = useCapabilitySpacesEnabled(store)

    useUpload({ uppyService })

    if (!uppyService.getPlugin('HandleUpload')) {
      uppyService.addPlugin(HandleUpload, {
        clientService,
        hasSpaces,
        language,
        route,
        space: props.space,
        store,
        uppyService
      })
    }

    let uploadCompletedSub

    const { actions: pasteFileActions } = useFileActionsPaste({ store })
    const pasteFileAction = unref(pasteFileActions)[0].handler

    const { actions: createNewFolder } = useFileActionsCreateNewFolder({
      store,
      space: props.space
    })
    const createNewFolderAction = computed(() => unref(createNewFolder)[0].handler)

    const newFileHandlers = computed(() => store.getters.newFileHandlers)

    const { actions: createNewFileActions } = useFileActionsCreateNewFile({
      store,
      space: props.space,
      newFileHandlers: newFileHandlers
    })

    const mimetypesAllowedForCreation = computed(() => {
      const mimeTypes = store.getters['External/mimeTypes']
      if (!mimeTypes) {
        return []
      }
      return mimeTypes.filter((mimetype) => mimetype.allow_creation) || []
    })

    const { actions: createNewFileMimeTypeActions } = useFileActionsCreateNewFile({
      store,
      space: props.space,
      mimetypesAllowedForCreation: mimetypesAllowedForCreation
    })

    const extensionRegistry = useExtensionRegistry()
    const extensionActions = computed(() => {
      return [
        ...extensionRegistry.requestExtensions<ActionExtension>('action').map((e) => e.action)
      ].filter((e) => e.isEnabled())
    })

    const currentFolder = computed(() => {
      return store.getters['Files/currentFolder']
    })
    const canUpload = computed(() => {
      return unref(currentFolder)?.canUpload({ user: store.getters.user })
    })

    const actionKeySuffix = ref(uuidv4())
    const showDrop = () => {
      // force actions to be re-rendered when the drop is being opened
      actionKeySuffix.value = uuidv4()
    }
    const isActionDisabled = (action: Action) => {
      return action.isDisabled ? action.isDisabled() : false
    }

    const handlePasteFileEvent = (event) => {
      // Ignore file in clipboard if there are already files from owncloud in the clipboard
      if (store.state.Files.clipboardResources.length || !unref(canUpload)) {
        return
      }
      // Browsers only allow single files to be pasted for security reasons
      const items = (event.clipboardData || event.originalEvent.clipboardData).items
      const fileItem = [...items].find((i) => i.kind === 'file')
      if (!fileItem) {
        return
      }
      const file = fileItem.getAsFile()
      uppyService.addFiles([file])
      event.preventDefault()
    }

    const onUploadComplete = async (result) => {
      if (result.successful) {
        const file = result.successful[0]

        if (!file) {
          return
        }

        store.dispatch('hideModal')
        const { spaceId, currentFolder, currentFolderId } = file.meta
        if (!['public', 'share'].includes(file.meta.driveType)) {
          if (unref(hasSpaces)) {
            const client = clientService.graphAuthenticated
            const driveResponse = await client.drives.getDrive(spaceId)
            store.commit('runtime/spaces/UPDATE_SPACE_FIELD', {
              id: driveResponse.data.id,
              field: 'spaceQuota',
              value: driveResponse.data.quota
            })
          } else {
            const user = await clientService.owncloudSdk.users.getUser(store.getters.user.id)
            store.commit('SET_QUOTA', user.quota)
          }
        }

        const sameFolder =
          props.itemId && !isShareSpaceResource(props.space)
            ? props.itemId.toString().startsWith(currentFolderId)
            : currentFolder === props.item
        const fileIsInCurrentPath = spaceId === props.space.id && sameFolder
        if (fileIsInCurrentPath) {
          eventBus.publish('app.files.list.load')
        }
      }
    }

    onMounted(() => {
      uploadCompletedSub = uppyService.subscribe('uploadCompleted', onUploadComplete)
      document.addEventListener('paste', handlePasteFileEvent)
    })

    onBeforeUnmount(() => {
      uppyService.removePlugin(uppyService.getPlugin('HandleUpload'))
      uppyService.unsubscribe('uploadCompleted', uploadCompletedSub)
      uppyService.removeDropTarget()
      document.removeEventListener('paste', handlePasteFileEvent)
    })

    watch(
      canUpload,
      () => {
        if (unref(canUpload)) {
          uppyService.useDropTarget({ targetSelector: '#files-view' })
        } else {
          uppyService.removeDropTarget()
        }
      },
      { immediate: true }
    )

    return {
      ...useFileActions({ store }),
      ...useRequest(),
      clientService,
      isPublicLocation: useActiveLocation(isLocationPublicActive, 'files-public-link'),
      isSpacesGenericLocation: useActiveLocation(isLocationSpacesActive, 'files-spaces-generic'),
      hasShareJail: useCapabilityShareJailEnabled(),
      hasSpaces: useCapabilitySpacesEnabled(),
      isUserContext: useUserContext({ store }),
      canUpload,
      currentFolder,
      createNewFileActions,
      createNewFileMimeTypeActions,
      createNewFolder,
      mimetypesAllowedForCreation,
      createNewFolderAction,
      extensionActions,
      pasteFileAction,
      isActionDisabled,
      actionKeySuffix,
      showDrop,

      // HACK: exported for unit tests:
      onUploadComplete
    }
  },
  computed: {
    ...mapGetters(['capabilities', 'configuration', 'newFileHandlers', 'user']),
    ...mapGetters('Files', ['ancestorMetaData', 'files', 'selectedFiles', 'clipboardResources']),
    ...mapGetters('runtime/spaces', ['spaces']),

    showPasteHereButton() {
      return this.clipboardResources && this.clipboardResources.length !== 0
    },
    hideButtonLabels() {
      return this.limitedScreenSpace && this.showPasteHereButton
    },

    showActions() {
      return !(this.uploadOrFileCreationBlocked && this.isPublicLocation)
    },

    createFileActionsAvailable() {
      return this.newFileHandlers.length > 0 || this.mimetypesAllowedForCreation.length > 0
    },
    newButtonTooltip() {
      if (!this.canUpload) {
        return this.$gettext('You have no permission to create new files!')
      }
      return null
    },
    newButtonAriaLabel() {
      const tooltip = this.newButtonTooltip
      if (tooltip) {
        return tooltip
      }
      if (!this.createFileActionsAvailable) {
        return this.$gettext('Create a new folder')
      }
      return this.$gettext('Create new files or folders')
    },
    uploadButtonTooltip() {
      if (!this.canUpload) {
        return this.$gettext('You have no permission to upload!')
      }
      return null
    },
    uploadButtonAriaLabel() {
      const tooltip = this.uploadButtonTooltip
      if (tooltip) {
        return tooltip
      }
      return this.$gettext('Upload files or folders')
    },

    uploadOrFileCreationBlocked() {
      return !this.canUpload
    },

    loadIndicatorsForNewFile() {
      return this.isSpacesGenericLocation && this.space.driveType !== 'share'
    },

    folderIconResource() {
      return { isFolder: true, extension: '' } as Resource
    }
  },
  methods: {
    ...mapActions('Files', ['clearClipboardFiles', 'pasteSelectedFiles']),
    ...mapActions(['showMessage', 'createModal', 'hideModal']),

    getIconResource(fileHandler) {
      return { type: 'file', extension: fileHandler.ext } as Resource
    }
  }
})
</script>
<style lang="scss">
#create-list {
  li {
    border: 1px solid transparent;

    button {
      gap: 10px;
      justify-content: left;
      width: 100%;
    }
  }

  .create-list-folder {
    border-bottom: 1px solid var(--oc-color-border);
  }

  .create-list-folder button {
    margin-bottom: 8px;
  }

  .create-list-file:nth-child(2) button {
    margin-top: 6px;
  }
}

#upload-list,
#new-file-menu-drop {
  min-width: 230px;
}

#create-list,
#upload-list,
#new-file-menu-drop {
  .oc-icon-m svg {
    height: 100% !important;
  }
}

#extension-list {
  border-top: 1px solid var(--oc-color-border);
}

#clipboard-btns {
  flex-flow: inherit;

  :nth-child(1) {
    border-right: 0px !important;
    white-space: nowrap;
  }

  :nth-child(2) {
    border-left: 0px !important;
  }
}

#clipboard-btns.disabled {
  opacity: 0.6;

  button {
    opacity: 1;
  }
}

.create-and-upload-actions {
  gap: var(--oc-space-small);
}
</style>
