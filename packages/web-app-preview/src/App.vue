<template>
  <main
    id="preview"
    ref="preview"
    tabindex="-1"
    @keydown.left="prev"
    @keydown.right="next"
    @keydown.esc="closeApp"
  >
    <h1 class="oc-invisible-sr" v-text="pageTitle" />
    <app-top-bar
      v-if="!isFileContentError"
      :resource="activeFilteredFile"
      :main-actions="fileActions"
      @close="closeApp"
    />

    <div v-if="isFolderLoading || isFileContentLoading" class="oc-position-center">
      <oc-spinner :aria-label="$gettext('Loading media file')" size="xlarge" />
    </div>
    <oc-icon
      v-else-if="isFileContentError"
      name="file-damage"
      variation="danger"
      size="xlarge"
      class="oc-position-center"
      :accessible-label="$gettext('Failed to load media file')"
    />
    <template v-else>
      <div
        v-show="activeMediaFileCached"
        class="oc-width-1-1 oc-flex oc-flex-center oc-flex-middle oc-p-s oc-box-shadow-medium preview-player"
        :class="{ lightbox: isFullScreenModeActivated }"
      >
        <media-image
          v-if="activeMediaFileCached.isImage"
          :file="activeMediaFileCached"
          :current-image-rotation="currentImageRotation"
          :current-image-zoom="currentImageZoom"
        />
        <media-video
          v-else-if="activeMediaFileCached.isVideo"
          :file="activeMediaFileCached"
          :is-auto-play-enabled="isAutoPlayEnabled"
        />
        <media-audio
          v-else-if="activeMediaFileCached.isAudio"
          :file="activeMediaFileCached"
          :is-auto-play-enabled="isAutoPlayEnabled"
        />
      </div>
    </template>
    <media-controls
      :files="filteredFiles"
      :active-index="activeIndex"
      :is-full-screen-mode-activated="isFullScreenModeActivated"
      :is-folder-loading="isFolderLoading"
      :is-image="activeMediaFileCached?.isImage"
      :current-image-rotation="currentImageRotation"
      :current-image-zoom="currentImageZoom"
      @set-rotation="currentImageRotation = $event"
      @set-zoom="currentImageZoom = $event"
      @toggle-full-screen="toggleFullscreenMode"
      @toggle-previous="prev"
      @toggle-next="next"
    />
  </main>
</template>
<script lang="ts">
import { computed, defineComponent, ref, unref } from 'vue'
import { RouteLocationRaw } from 'vue-router'
import { Resource } from 'web-client/src'
import AppTopBar from 'web-pkg/src/components/AppTopBar.vue'
import {
  queryItemAsString,
  sortHelper,
  useAppDefaults,
  useRoute,
  useRouteQuery,
  useRouter
} from 'web-pkg/src/composables'
import { Action, ActionOptions } from 'web-pkg/src/composables/actions/types'
import { useDownloadFile } from 'web-pkg/src/composables/download/useDownloadFile'
import { createFileRouteOptions } from 'web-pkg/src/helpers/router'
import MediaControls from './components/MediaControls.vue'
import MediaAudio from './components/Sources/MediaAudio.vue'
import MediaImage from './components/Sources/MediaImage.vue'
import MediaVideo from './components/Sources/MediaVideo.vue'
import { CachedFile } from './helpers/types'

export const appId = 'preview'

export const mimeTypes = () => {
  return [
    'audio/flac',
    'audio/mpeg',
    'audio/ogg',
    'audio/wav',
    'audio/x-flac',
    'audio/x-wav',
    'image/gif',
    'image/jpeg',
    'image/png',
    'video/mp4',
    'video/webm',
    ...((window as any).__$store?.getters.extensionConfigByAppId(appId).mimeTypes || [])
  ]
}

export default defineComponent({
  name: 'Preview',
  components: {
    AppTopBar,
    MediaControls,
    MediaAudio,
    MediaImage,
    MediaVideo
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const appDefaults = useAppDefaults({ applicationId: 'preview' })
    const contextRouteQuery = useRouteQuery('contextRouteQuery')
    const { downloadFile } = useDownloadFile()

    const activeIndex = ref()
    const cachedFiles = ref<CachedFile[]>([])

    const sortBy = computed(() => {
      if (!unref(contextRouteQuery)) {
        return 'name'
      }
      return unref(contextRouteQuery)['sort-by'] ?? 'name'
    })
    const sortDir = computed(() => {
      if (!unref(contextRouteQuery)) {
        return 'desc'
      }
      return unref(contextRouteQuery)['sort-dir'] ?? 'asc'
    })

    const { activeFiles, currentFileContext } = appDefaults

    const isFullScreenModeActivated = ref(false)
    const toggleFullscreenMode = () => {
      const activateFullscreen = !unref(isFullScreenModeActivated)
      isFullScreenModeActivated.value = activateFullscreen
      if (activateFullscreen) {
        if (document.documentElement.requestFullscreen) {
          document.documentElement.requestFullscreen()
        }
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen()
        }
      }
    }

    const filteredFiles = computed<Resource[]>(() => {
      if (!unref(activeFiles)) {
        return []
      }

      const files = unref(activeFiles).filter((file) => {
        return mimeTypes().includes(file.mimeType?.toLowerCase())
      })

      return sortHelper(files, [{ name: unref(sortBy) }], unref(sortBy), unref(sortDir))
    })
    const activeFilteredFile = computed(() => {
      return unref(filteredFiles)[unref(activeIndex)]
    })
    const activeMediaFileCached = computed(() => {
      return unref(cachedFiles).find((i) => i.id === unref(activeFilteredFile).id)
    })

    const updateLocalHistory = () => {
      const { params, query } = createFileRouteOptions(
        unref(unref(currentFileContext).space),
        unref(activeFilteredFile)
      )
      router.replace({
        ...unref(route),
        params: { ...unref(route).params, ...params },
        query: { ...unref(route).query, ...query }
      })
    }
    const isFileContentLoading = ref(true)

    const triggerActiveFileDownload = () => {
      if (isFileContentLoading.value) {
        return
      }
      downloadFile(activeFilteredFile.value)
    }

    const fileActions: Action<ActionOptions>[] = [
      {
        name: 'download-file',
        isEnabled: () => true,
        componentType: 'button',
        icon: 'file-download',
        id: 'preview-download',
        label: () => 'Download',
        handler: () => {
          triggerActiveFileDownload()
        }
      }
    ]

    return {
      ...appDefaults,
      activeFilteredFile,
      activeIndex,
      activeMediaFileCached,
      cachedFiles,
      filteredFiles,
      fileActions,
      isFileContentLoading,
      isFullScreenModeActivated,
      toggleFullscreenMode,
      updateLocalHistory
    }
  },
  data() {
    return {
      isFileContentError: false,
      isAutoPlayEnabled: true,

      toPreloadImageIds: [],

      currentImageZoom: 1,
      currentImageRotation: 0,

      preloadImageCount: 10
    }
  },

  computed: {
    pageTitle() {
      return this.$gettext('Preview for %{currentMediumName}', {
        currentMediumName: this.activeFilteredFile?.name
      })
    },
    thumbDimensions() {
      switch (true) {
        case window.innerWidth <= 1024:
          return 1024
        case window.innerWidth <= 1280:
          return 1280
        case window.innerWidth <= 1920:
          return 1920
        case window.innerWidth <= 2160:
          return 2160
        default:
          return 3840
      }
    },
    isActiveFileTypeImage() {
      return !this.isActiveFileTypeAudio && !this.isActiveFileTypeVideo
    },
    isActiveFileTypeAudio() {
      return this.isFileTypeAudio(this.activeFilteredFile)
    },
    isActiveFileTypeVideo() {
      return this.isFileTypeVideo(this.activeFilteredFile)
    }
  },

  watch: {
    activeIndex(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.loadMedium()
        this.preloadImages()
      }

      if (oldValue !== null) {
        this.isAutoPlayEnabled = false
      }

      this.currentImageZoom = 1
      this.currentImageRotation = 0
    }
  },

  async mounted() {
    // keep a local history for this component
    window.addEventListener('popstate', this.handleLocalHistoryEvent)
    document.addEventListener('fullscreenchange', this.handleFullScreenChangeEvent)
    await this.loadFolderForFileContext(this.currentFileContext)
    this.setActiveFile(unref(this.currentFileContext.driveAliasAndItem))
    ;(this.$refs.preview as HTMLElement).focus()
  },

  beforeUnmount() {
    window.removeEventListener('popstate', this.handleLocalHistoryEvent)
    document.removeEventListener('fullscreenchange', this.handleFullScreenChangeEvent)

    this.cachedFiles.forEach((medium) => {
      this.revokeUrl(medium.url)
    })
  },

  methods: {
    setActiveFile(driveAliasAndItem: string) {
      for (let i = 0; i < this.filteredFiles.length; i++) {
        if (
          unref(this.currentFileContext.space)?.getDriveAliasAndItem(this.filteredFiles[i]) ===
          driveAliasAndItem
        ) {
          this.activeIndex = i
          return
        }
      }

      this.isFileContentLoading = false
      this.isFileContentError = true
    },
    // react to PopStateEvent ()
    handleLocalHistoryEvent() {
      const result = this.$router.resolve(document.location as unknown as RouteLocationRaw)
      this.setActiveFile(queryItemAsString(result.params.driveAliasAndItem))
    },
    handleFullScreenChangeEvent() {
      if (document.fullscreenElement === null) {
        this.isFullScreenModeActivated = false
      }
    },
    loadMedium() {
      this.isFileContentLoading = true

      // Don't bother loading if file is already loaded and cached
      if (this.activeMediaFileCached) {
        setTimeout(
          () => {
            this.isFileContentLoading = false
          },
          // Delay to animate
          50
        )
        return
      }

      this.loadActiveFileIntoCache()
    },
    async loadActiveFileIntoCache() {
      try {
        const loadRawFile = !this.isActiveFileTypeImage
        let mediaUrl
        if (loadRawFile) {
          mediaUrl = await this.getUrlForResource(
            unref(this.currentFileContext.space),
            this.activeFilteredFile
          )
        } else {
          mediaUrl = await this.loadPreview(this.activeFilteredFile)
        }

        this.addPreviewToCache(this.activeFilteredFile, mediaUrl)
        this.isFileContentLoading = false
        this.isFileContentError = false
      } catch (e) {
        this.isFileContentLoading = false
        this.isFileContentError = true
        console.error(e)
      }
    },
    next() {
      if (this.isFileContentLoading) {
        return
      }
      this.isFileContentError = false
      if (this.activeIndex + 1 >= this.filteredFiles.length) {
        this.activeIndex = 0
        this.updateLocalHistory()
        return
      }
      this.activeIndex++
      this.updateLocalHistory()
    },
    prev() {
      if (this.isFileContentLoading) {
        return
      }
      this.isFileContentError = false
      if (this.activeIndex === 0) {
        this.activeIndex = this.filteredFiles.length - 1
        this.updateLocalHistory()
        return
      }
      this.activeIndex--
      this.updateLocalHistory()
    },
    isFileTypeImage(file) {
      return !this.isFileTypeAudio(file) && !this.isFileTypeVideo(file)
    },
    isFileTypeAudio(file) {
      return file.mimeType.toLowerCase().startsWith('audio')
    },

    isFileTypeVideo(file) {
      return file.mimeType.toLowerCase().startsWith('video')
    },
    addPreviewToCache(file, url) {
      this.cachedFiles.push({
        id: file.id,
        name: file.name,
        url,
        ext: file.extension,
        mimeType: file.mimeType,
        isVideo: this.isFileTypeVideo(file),
        isImage: this.isFileTypeImage(file),
        isAudio: this.isFileTypeAudio(file)
      })
    },
    loadPreview(file) {
      return this.$previewService.loadPreview({
        space: unref(this.currentFileContext.space),
        resource: file,
        dimensions: [this.thumbDimensions, this.thumbDimensions] as [number, number]
      })
    },
    preloadImages() {
      const loadPreviewAsync = (file) => {
        this.toPreloadImageIds.push(file.id)
        this.loadPreview(file)

          .then((mediaUrl) => {
            this.addPreviewToCache(file, mediaUrl)
          })
          .catch((e) => {
            console.error(e)
            this.toPreloadImageIds = this.toPreloadImageIds.filter((fileId) => fileId !== file.id)
          })
      }

      const preloadFile = (preloadFileIndex) => {
        let cycleIndex =
          (((this.activeIndex + preloadFileIndex) % this.filteredFiles.length) +
            this.filteredFiles.length) %
          this.filteredFiles.length

        const file = this.filteredFiles[cycleIndex]

        if (!this.isFileTypeImage(file) || this.toPreloadImageIds.includes(file.id)) {
          return
        }

        loadPreviewAsync(file)
      }

      for (
        let followingFileIndex = 1;
        followingFileIndex <= this.preloadImageCount;
        followingFileIndex++
      ) {
        preloadFile(followingFileIndex)
      }

      for (
        let previousFileIndex = -1;
        previousFileIndex >= this.preloadImageCount * -1;
        previousFileIndex--
      ) {
        preloadFile(previousFileIndex)
      }
    }
  }
})
</script>

<style lang="scss" scoped>
.preview-player {
  overflow: auto;
  max-width: 90vw;
  height: 70vh;
  margin: 10px auto;
  object-fit: contain;

  img,
  video {
    max-width: 85vw;
    max-height: 65vh;
  }
}
.preview-player.lightbox {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 999;
  margin: 0;
  background: rgba(38, 38, 38, 0.8);
  width: 100%;
  height: 100%;
  max-width: 100%;
}

.preview-player.lightbox > * {
  max-width: 100vw;
  max-height: 100vh;
}

.preview-details.lightbox {
  z-index: 1000;
  opacity: 0.9;
}

@media (max-width: 959px) {
  .preview-player {
    max-width: 100vw;
  }
}
</style>
