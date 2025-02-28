<template>
  <main class="oc-flex oc-flex-wrap oc-height-1-1 app-content oc-width-1-1">
    <app-loading-spinner v-if="loading" />
    <template v-else>
      <div id="admin-settings-wrapper" class="oc-width-expand oc-height-1-1 oc-position-relative">
        <div id="admin-settings-app-bar" ref="appBarRef" class="oc-app-bar oc-py-s">
          <div class="admin-settings-app-bar-controls oc-flex oc-flex-between oc-flex-middle">
            <oc-breadcrumb
              v-if="!isMobileWidth"
              id="admin-settings-breadcrumb"
              class="oc-flex oc-flex-middle"
              :items="breadcrumbs"
            />
            <portal-target name="app.runtime.mobile.nav" />
            <div class="oc-flex">
              <view-options
                v-if="showViewOptions"
                :has-hidden-files="false"
                :has-file-extensions="false"
                :has-pagination="true"
                :pagination-options="paginationOptions"
                :per-page-default="perPageDefault"
                per-page-storage-prefix="admin-settings"
              />
              <oc-button
                v-if="sideBarAvailablePanels.length"
                id="files-toggle-sidebar"
                v-oc-tooltip="toggleSidebarButtonLabel"
                :aria-label="toggleSidebarButtonLabel"
                appearance="raw"
                class="oc-my-s oc-p-xs"
                @click.stop="toggleSideBar"
              >
                <oc-icon name="side-bar-right" :fill-type="toggleSidebarButtonIconFillType" />
              </oc-button>
            </div>
          </div>
          <div
            v-if="showAppBar"
            class="admin-settings-app-bar-actions oc-flex oc-flex-middle oc-mt-xs"
          >
            <slot name="topbarActions" class="oc-flex-1 oc-flex oc-flex-start" />
            <batch-actions
              v-if="showBatchActions"
              :actions="batchActions"
              :action-options="{ resources: batchActionItems }"
              :limited-screen-space="limitedScreenSpace"
            />
          </div>
        </div>
        <slot name="mainContent" />
      </div>
      <side-bar
        v-if="sideBarOpen"
        :active-panel="sideBarActivePanel"
        :available-panels="sideBarAvailablePanels"
        :loading="sideBarLoading"
        :open="sideBarOpen"
        :is-header-compact="isSideBarHeaderCompact"
        @select-panel="selectPanel"
        @close="closeSideBar"
      >
        <template #header>
          <slot name="sideBarHeader" />
        </template>
      </side-bar>
    </template>
  </main>
</template>

<script lang="ts">
import { perPageDefault, paginationOptions } from 'web-app-admin-settings/src/defaults'
import AppLoadingSpinner from 'web-pkg/src/components/AppLoadingSpinner.vue'
import SideBar from 'web-pkg/src/components/SideBar/SideBar.vue'
import BatchActions from 'web-pkg/src/components/BatchActions.vue'
import {
  defineComponent,
  inject,
  onBeforeUnmount,
  PropType,
  Ref,
  ref,
  unref,
  VNodeRef,
  watch
} from 'vue'
import { eventBus, useAppDefaults } from 'web-pkg'
import { SideBarEventTopics } from 'web-pkg/src/composables/sideBar'
import { Panel } from 'web-pkg/src/components/SideBar'
import { BreadcrumbItem } from 'design-system/src/components/OcBreadcrumb/types'
import ViewOptions from 'web-pkg/src/components/ViewOptions.vue'

export default defineComponent({
  components: {
    SideBar,
    AppLoadingSpinner,
    BatchActions,
    ViewOptions
  },
  props: {
    breadcrumbs: {
      required: true,
      type: Array as PropType<BreadcrumbItem[]>
    },
    sideBarOpen: {
      required: false,
      type: Boolean,
      default: false
    },
    sideBarAvailablePanels: {
      required: false,
      type: Array as PropType<Panel[]>,
      default: () => []
    },
    sideBarActivePanel: {
      required: false,
      type: [String, null],
      default: null
    },
    loading: {
      required: false,
      type: Boolean,
      default: false
    },
    sideBarLoading: {
      required: false,
      type: Boolean,
      default: false
    },
    isSideBarHeaderCompact: {
      required: false,
      type: Boolean,
      default: false
    },
    showViewOptions: {
      type: Boolean,
      required: false,
      default: false
    },
    showBatchActions: {
      type: Boolean,
      required: false,
      default: false
    },
    batchActionItems: {
      type: Array as PropType<any>,
      required: false,
      default: () => []
    },
    batchActions: {
      type: Array as PropType<any>,
      required: false,
      default: () => []
    },
    showAppBar: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  setup(props) {
    const appBarRef = ref<VNodeRef>()
    const limitedScreenSpace = ref(false)
    const onResize = () => {
      limitedScreenSpace.value = props.sideBarOpen
        ? window.innerWidth <= 1600
        : window.innerWidth <= 1200
    }
    const resizeObserver = new ResizeObserver(onResize)

    const closeSideBar = () => {
      eventBus.publish(SideBarEventTopics.close)
    }
    const toggleSideBar = () => {
      eventBus.publish(SideBarEventTopics.toggle)
    }
    const selectPanel = (panel) => {
      eventBus.publish(SideBarEventTopics.setActivePanel, panel)
    }

    watch(
      appBarRef,
      (ref) => {
        if (ref) {
          resizeObserver.observe(unref(appBarRef) as unknown as HTMLElement)
        }
      },
      { immediate: true }
    )

    onBeforeUnmount(() => {
      if (unref(appBarRef)) {
        resizeObserver.unobserve(unref(appBarRef) as unknown as HTMLElement)
      }
    })

    return {
      isMobileWidth: inject<Ref<boolean>>('isMobileWidth'),
      appBarRef,
      limitedScreenSpace,
      closeSideBar,
      toggleSideBar,
      selectPanel,
      ...useAppDefaults({
        applicationId: 'admin-settings'
      }),
      perPageDefault,
      paginationOptions
    }
  },
  computed: {
    toggleSidebarButtonLabel() {
      return this.sideBarOpen
        ? this.$gettext('Close sidebar to hide details')
        : this.$gettext('Open sidebar to view details')
    },
    toggleSidebarButtonIconFillType() {
      return this.sideBarOpen ? 'fill' : 'line'
    }
  }
})
</script>

<style lang="scss">
#admin-settings-wrapper {
  overflow-y: auto;
}

#admin-settings-app-bar {
  background-color: var(--oc-color-background-default);
  border-top-right-radius: 15px;
  box-sizing: border-box;
  z-index: 2;
  position: sticky;
  padding: 0 var(--oc-space-medium);
  top: 0;
}

#files-toggle-sidebar {
  vertical-align: middle;
  border: 3px solid transparent;
  &:hover {
    background-color: var(--oc-color-background-hover);
    border-radius: 3px;
  }
}

.admin-settings-app-bar-controls {
  height: 52px;

  @media (max-width: $oc-breakpoint-xsmall-max) {
    justify-content: space-between;
  }
}

.admin-settings-app-bar-actions {
  align-items: center;
  display: flex;
  min-height: 3rem;
}

#admin-settings-wrapper {
  overflow-y: auto;
}
</style>
