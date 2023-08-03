import { Store } from 'vuex'
import { computed, Ref, ref, unref } from 'vue'
import { dirname } from 'path'
import { ClientService, MaybeRef } from 'web-pkg'
import { useAppFileHandling } from 'web-pkg/src/composables'
import { Resource } from 'web-client'
import { FileContext } from './types'
import { RouteLocationNormalizedLoaded } from 'vue-router'
import { useFileRouteReplace } from '../router/useFileRouteReplace'
import { DavProperty } from 'web-client/src/webdav/constants'
import { useAuthService } from '../authContext/useAuthService'

interface AppFolderHandlingOptions {
  store: Store<any>
  currentRoute: Ref<RouteLocationNormalizedLoaded>
  clientService?: ClientService
}

export interface AppFolderHandlingResult {
  isFolderLoading: Ref<boolean>
  activeFiles: Ref<Array<Resource>>

  loadFolderForFileContext(context: MaybeRef<FileContext>): Promise<any>
}

export function useAppFolderHandling({
  store,
  currentRoute,
  clientService
}: AppFolderHandlingOptions): AppFolderHandlingResult {
  const isFolderLoading = ref(false)
  const activeFiles = computed(() => {
    return store.getters['Files/activeFiles']
  })
  const { webdav } = clientService
  const { replaceInvalidFileRoute } = useFileRouteReplace()
  const { getFileInfo } = useAppFileHandling({ clientService })
  const authService = useAuthService()

  const loadFolderForFileContext = async (context: MaybeRef<FileContext>) => {
    if (store.getters.activeFile && store.getters.activeFile.path !== '') {
      return
    }

    isFolderLoading.value = true
    store.commit('Files/CLEAR_CURRENT_FILES_LIST', null)
    try {
      context = unref(context)
      const space = unref(context.space)

      const pathResource = await getFileInfo(context, {
        davProperties: [DavProperty.FileId]
      })
      await replaceInvalidFileRoute({
        space,
        resource: pathResource,
        path: unref(context.item),
        fileId: unref(context.itemId)
      })

      const path = dirname(pathResource.path)
      const { resource, children } = await webdav.listFiles(space, {
        path
      })

      if (resource.type === 'file') {
        store.commit('Files/LOAD_FILES', {
          currentFolder: resource,
          files: [resource]
        })
      } else {
        store.commit('Files/LOAD_FILES', {
          currentFolder: resource,
          files: children
        })
      }
    } catch (error) {
      if (error.statusCode === 401) {
        return authService.handleAuthError(unref(currentRoute))
      }
      store.commit('Files/SET_CURRENT_FOLDER', null)
      console.error(error)
    }
    isFolderLoading.value = false
  }

  return {
    isFolderLoading,
    loadFolderForFileContext,
    activeFiles
  }
}
