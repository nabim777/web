<template>
  <div id="files-app-bar" ref="filesAppBar" :class="{ 'files-app-bar-squashed': sideBarOpen }">
    <oc-hidden-announcer :announcement="selectedResourcesAnnouncement" level="polite" />
    <div class="files-topbar oc-py-s">
      <h1 class="oc-invisible-sr" v-text="pageTitle" />
      <div
        class="oc-flex oc-flex-middle files-app-bar-controls"
        :class="{
          'oc-flex-between': breadcrumbs.length || hasSharesNavigation,
          'oc-flex-right': !breadcrumbs.length && !hasSharesNavigation
        }"
      >
        <oc-breadcrumb
          v-if="showBreadcrumb"
          id="files-breadcrumb"
          data-testid="files-breadcrumbs"
          class="oc-flex oc-flex-middle"
          context-menu-padding="small"
          :show-context-actions="showContextActions"
          :items="breadcrumbs"
          :max-width="breadcrumbMaxWidth"
          :truncation-offset="breadcrumbTruncationOffset"
          @item-dropped-breadcrumb="fileDroppedBreadcrumb"
        >
          <template #contextMenu>
            <context-actions
              :action-options="{ space, resources: breadcrumbsContextActionsItems.filter(Boolean) }"
            />
          </template>
        </oc-breadcrumb>
        <portal-target v-if="showMobileNav" name="app.runtime.mobile.nav" />
        <shares-navigation v-if="hasSharesNavigation" />
        <div
          v-if="hasViewOptions || hasSidebarToggle"
          id="files-app-bar-controls-right"
          class="oc-flex"
        >
          <view-options
            v-if="hasViewOptions"
            :view-modes="viewModes"
            :has-hidden-files="hasHiddenFiles"
            :has-file-extensions="hasFileExtensions"
            :has-pagination="hasPagination"
            per-page-storage-prefix="files"
            :view-mode-default="viewModeDefault"
          />
          <sidebar-toggle v-if="hasSidebarToggle" :side-bar-open="sideBarOpen" />
        </div>
      </div>
      <div class="files-app-bar-actions oc-mt-xs">
        <div class="oc-flex-1 oc-flex oc-flex-start oc-flex-middle">
          <slot name="actions" :limited-screen-space="limitedScreenSpace" />
          <batch-actions
            v-if="showBatchActions"
            :actions="batchActions"
            :action-options="{ space, resources: selectedFiles }"
            :limited-screen-space="limitedScreenSpace"
          />
        </div>
      </div>
      <slot name="content" />
    </div>
  </div>
</template>

<script lang="ts">
import last from 'lodash-es/last'
import { computed, defineComponent, inject, PropType, ref, Ref, unref } from 'vue'
import { mapGetters, mapState, mapMutations } from 'vuex'
import { Resource } from 'web-client'
import {
  isPersonalSpaceResource,
  isProjectSpaceResource,
  isShareSpaceResource,
  SpaceResource
} from 'web-client/src/helpers'
import BatchActions from 'web-pkg/src/components/BatchActions.vue'
import { isLocationTrashActive } from '../../router'
import ContextActions from '../FilesList/ContextActions.vue'
import SharesNavigation from './SharesNavigation.vue'
import SidebarToggle from './SidebarToggle.vue'
import { ViewMode } from 'web-pkg/src/ui/types'
import {
  useFileActionsAcceptShare,
  useFileActionsCopy,
  useFileActionsDeclineShare,
  useFileActionsDelete,
  useFileActionsDownloadArchive,
  useFileActionsDownloadFile,
  useFileActionsEmptyTrashBin,
  useFileActionsMove,
  useFileActionsRestore
} from 'web-app-files/src/composables/actions'
import { useRouteMeta, useStore, ViewModeConstants } from 'web-pkg/src/composables'
import { BreadcrumbItem } from 'design-system/src/components/OcBreadcrumb/types'
import { useActiveLocation } from 'web-app-files/src/composables'
import { EVENT_ITEM_DROPPED } from 'design-system/src/helpers'
import ViewOptions from 'web-pkg/src/components/ViewOptions.vue'
import { useGettext } from 'vue3-gettext'

export default defineComponent({
  components: {
    BatchActions,
    ContextActions,
    SharesNavigation,
    SidebarToggle,
    ViewOptions
  },
  props: {
    viewModeDefault: {
      type: String,
      required: false,
      default: ViewModeConstants.default.name
    },
    breadcrumbs: {
      type: Array as PropType<BreadcrumbItem[]>,
      default: () => []
    },
    breadcrumbsContextActionsItems: {
      type: Array as PropType<Resource[]>,
      default: () => []
    },
    viewModes: {
      type: Array as PropType<ViewMode[]>,
      default: () => []
    },
    hasBulkActions: { type: Boolean, default: false },
    hasSharesNavigation: { type: Boolean, default: false },
    hasSidebarToggle: { type: Boolean, default: true },
    hasViewOptions: { type: Boolean, default: true },
    hasHiddenFiles: { type: Boolean, default: true },
    hasFileExtensions: { type: Boolean, default: true },
    hasPagination: { type: Boolean, default: true },
    showActionsOnSelection: { type: Boolean, default: false },
    sideBarOpen: { type: Boolean, default: false },
    space: {
      type: Object as PropType<SpaceResource>,
      required: false,
      default: null
    }
  },
  setup(props, { emit }) {
    const store = useStore()
    const { $gettext } = useGettext()

    const { actions: acceptShareActions } = useFileActionsAcceptShare({ store })
    const { actions: copyActions } = useFileActionsCopy({ store })
    const { actions: declineShareActions } = useFileActionsDeclineShare({ store })
    const { actions: deleteActions } = useFileActionsDelete({ store })
    const { actions: downloadArchiveActions } = useFileActionsDownloadArchive({ store })
    const { actions: downloadFileActions } = useFileActionsDownloadFile()
    const { actions: emptyTrashBinActions } = useFileActionsEmptyTrashBin({ store })
    const { actions: moveActions } = useFileActionsMove({ store })
    const { actions: restoreActions } = useFileActionsRestore({ store })

    const breadcrumbMaxWidth = ref<number>(0)

    const batchActions = computed(() => {
      return [
        ...unref(acceptShareActions),
        ...unref(declineShareActions),
        ...unref(downloadArchiveActions),
        ...unref(downloadFileActions),
        ...unref(moveActions),
        ...unref(copyActions),
        ...unref(emptyTrashBinActions),
        ...unref(deleteActions),
        ...unref(restoreActions)
      ].filter((item) =>
        item.isEnabled({ space: props.space, resources: store.getters['Files/selectedFiles'] })
      )
    })

    const spaces = computed<SpaceResource[]>(() =>
      store.getters['runtime/spaces/spaces'].filter(
        (s) => isPersonalSpaceResource(s) || isProjectSpaceResource(s)
      )
    )

    const isMobileWidth = inject<Ref<boolean>>('isMobileWidth')
    const isTrashLocation = useActiveLocation(isLocationTrashActive, 'files-trash-generic')
    const showBreadcrumb = computed(() => {
      if (!unref(isMobileWidth) && props.breadcrumbs.length) {
        return true
      }
      if (unref(isTrashLocation) && unref(spaces).length === 1) {
        return false
      }
      return props.breadcrumbs.length > 1
    })
    const showMobileNav = computed(() => {
      if (unref(isTrashLocation) && unref(spaces).length === 1) {
        return props.breadcrumbs.length <= 2
      }
      return props.breadcrumbs.length <= 1
    })

    const breadcrumbTruncationOffset = computed(() => {
      if (!props.space) {
        return 2
      }
      return isProjectSpaceResource(unref(props.space)) || isShareSpaceResource(unref(props.space))
        ? 3
        : 2
    })
    const fileDroppedBreadcrumb = async (data) => {
      emit(EVENT_ITEM_DROPPED, data)
    }

    const routeMetaTitle = useRouteMeta('title')
    const pageTitle = computed(() => {
      if (unref(routeMetaTitle)) {
        return $gettext(unref(routeMetaTitle))
      }
      return props.space?.name || ''
    })

    return {
      batchActions,
      showBreadcrumb,
      showMobileNav,
      breadcrumbMaxWidth,
      breadcrumbTruncationOffset,
      fileDroppedBreadcrumb,
      pageTitle
    }
  },
  data: function () {
    return {
      resizeObserver: new ResizeObserver(this.onResize as ResizeObserverCallback),
      limitedScreenSpace: false
    }
  },
  computed: {
    ...mapGetters('Files', ['files', 'selectedFiles']),
    ...mapState('Files', ['areHiddenFilesShown', 'areFileExtensionsShown']),

    showContextActions() {
      return last<BreadcrumbItem>(this.breadcrumbs).allowContextActions
    },
    showBatchActions() {
      return (
        this.hasBulkActions &&
        (this.selectedFiles.length >= 1 ||
          isLocationTrashActive(this.$router, 'files-trash-generic'))
      )
    },
    selectedResourcesAnnouncement() {
      if (this.selectedFiles.length === 0) {
        return this.$gettext('No items selected.')
      }
      return this.$ngettext(
        '%{ amount } item selected. Actions are available above the table.',
        '%{ amount } items selected. Actions are available above the table.',
        this.selectedFiles.length,
        {
          amount: this.selectedFiles.length
        }
      )
    }
  },
  mounted() {
    this.resizeObserver.observe(this.$refs.filesAppBar as HTMLElement)
    window.addEventListener('resize', this.onResize)
  },
  beforeUnmount() {
    this.resizeObserver.unobserve(this.$refs.filesAppBar as HTMLElement)
    window.removeEventListener('resize', this.onResize)
  },

  created() {
    // Storage returns a string so we need to convert it into a boolean
    const areHiddenFilesShown = window.localStorage.getItem('oc_hiddenFilesShown') || 'false'
    const areHiddenFilesShownBoolean = areHiddenFilesShown === 'true'

    if (areHiddenFilesShownBoolean !== this.areHiddenFilesShown) {
      this.SET_HIDDEN_FILES_VISIBILITY(areHiddenFilesShownBoolean)
    }

    // Storage returns a string so we need to convert it into a boolean
    const areFileExtensionsShown = window.localStorage.getItem('oc_fileExtensionsShown') || 'true'
    const areFileExtensionsShownBoolean = areFileExtensionsShown === 'true'

    if (areFileExtensionsShownBoolean !== this.areFileExtensionsShown) {
      this.SET_FILE_EXTENSIONS_VISIBILITY(areFileExtensionsShownBoolean)
    }
  },

  methods: {
    ...mapMutations('Files', ['SET_HIDDEN_FILES_VISIBILITY', 'SET_FILE_EXTENSIONS_VISIBILITY']),

    onResize() {
      const totalContentWidth =
        document.getElementById('web-content-main')?.getBoundingClientRect().width || 0
      const leftSidebarWidth =
        document.getElementById('web-nav-sidebar')?.getBoundingClientRect().width || 0
      const rightSidebarWidth =
        document.getElementById('app-sidebar')?.getBoundingClientRect().width || 0

      const rightControlsWidth = document.getElementById(
        'files-app-bar-controls-right'
      )?.clientWidth

      this.breadcrumbMaxWidth =
        totalContentWidth - leftSidebarWidth - rightSidebarWidth - rightControlsWidth
      this.limitedScreenSpace = this.sideBarOpen
        ? window.innerWidth <= 1280
        : window.innerWidth <= 1000
    }
  }
})
</script>

<style lang="scss" scoped>
#files-app-bar {
  background-color: var(--oc-color-background-default);
  border-top-right-radius: 15px;
  box-sizing: border-box;
  z-index: 2;
  position: sticky;
  padding: 0 var(--oc-space-medium);
  top: 0;

  .files-app-bar-controls {
    min-height: 52px;

    @media (max-width: $oc-breakpoint-xsmall-max) {
      justify-content: space-between;
    }
  }

  .files-app-bar-actions {
    align-items: center;
    display: flex;
    gap: var(--oc-space-small);
    justify-content: flex-end;
    min-height: 3rem;
  }

  #files-breadcrumb {
    min-height: 2rem;
  }
}
</style>
