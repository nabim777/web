<template>
  <div class="files-search-result oc-flex">
    <files-view-wrapper>
      <app-bar :breadcrumbs="breadcrumbs" :has-bulk-actions="true" :side-bar-open="sideBarOpen" />
      <div v-if="displayFilter" class="files-search-result-filter oc-flex oc-mx-m oc-mb-m oc-mt-xs">
        <div class="oc-mr-m oc-flex oc-flex-middle">
          <oc-icon name="filter-2" class="oc-mr-xs" />
          <span v-text="$gettext('Filter:')" />
        </div>
        <item-filter
          v-if="availableTags.length"
          ref="tagFilter"
          :filter-label="$gettext('Tags')"
          :filterable-attributes="['label']"
          :items="availableTags"
          :option-filter-label="$gettext('Filter tags')"
          :show-option-filter="true"
          :close-on-click="true"
          class="files-search-filter-tags oc-mr-s"
          display-name-attribute="label"
          filter-name="tags"
        >
          <template #image="{ item }">
            <oc-avatar :width="24" :user-name="item.label" />
          </template>
          <template #item="{ item }">
            <span v-text="item.label" />
          </template>
        </item-filter>
        <item-filter-toggle
          v-if="fullTextSearchEnabled"
          :filter-label="$gettext('Search only in content')"
          filter-name="fullText"
          class="files-search-filter-full-text oc-mr-s"
        />
      </div>
      <app-loading-spinner v-if="loading" />
      <template v-else>
        <no-content-message
          v-if="!paginatedResources.length"
          class="files-empty"
          icon="search"
          icon-fill-type="line"
        >
          <template #message>
            <p class="oc-text-muted">
              <span v-if="!!$route.query.term" v-text="$gettext('No results found')" />
              <span v-else v-text="$gettext('Search for files')" />
            </p>
          </template>
        </no-content-message>
        <resource-table
          v-else
          v-model:selectedIds="selectedResourcesIds"
          class="files-table"
          :class="{ 'files-table-squashed': false }"
          :header-position="fileListHeaderY"
          :resources="paginatedResources"
          :are-paths-displayed="true"
          :are-thumbnails-displayed="displayThumbnails"
          :has-actions="true"
          :is-selectable="true"
          :sort-by="sortBy"
          :sort-dir="sortDir"
          :fields-displayed="['name', 'size', 'tags', 'mdate']"
          @file-click="triggerDefaultAction"
          @row-mounted="rowMounted"
          @sort="handleSort"
        >
          <template #additionalResourceContent="{ resource }">
            <span
              v-if="resource.highlights"
              class="files-search-resource-highlights oc-text-truncate"
              v-html="resource.highlights"
            />
          </template>
          <template #contextMenu="{ resource }">
            <context-actions
              v-if="isResourceInSelection(resource)"
              :action-options="{ space: getSpace(resource), resources: selectedResources }"
            />
          </template>
          <template #footer>
            <pagination :pages="paginationPages" :current-page="paginationPage" />
            <div
              v-if="searchResultExceedsLimit"
              class="oc-text-nowrap oc-text-center oc-width-1-1 oc-my-s"
              v-text="searchResultExceedsLimitText"
            />
            <list-info
              v-else-if="paginatedResources.length > 0"
              class="oc-width-1-1 oc-my-s"
              :files="totalFilesCount.files"
              :folders="totalFilesCount.folders"
              :size="totalFilesSize"
            />
          </template>
        </resource-table>
      </template>
    </files-view-wrapper>
    <side-bar
      :open="sideBarOpen"
      :active-panel="sideBarActivePanel"
      :space="selectedResourceSpace"
    />
  </div>
</template>

<script lang="ts">
import { useResourcesViewDefaults } from '../../composables'
import AppLoadingSpinner from 'web-pkg/src/components/AppLoadingSpinner.vue'
import { VisibilityObserver } from 'web-pkg/src/observer'
import { ImageType, ImageDimension } from 'web-pkg/src/constants'
import NoContentMessage from 'web-pkg/src/components/NoContentMessage.vue'
import ResourceTable from '../FilesList/ResourceTable.vue'
import ContextActions from '../FilesList/ContextActions.vue'
import { debounce } from 'lodash-es'
import { mapMutations, mapGetters, mapActions } from 'vuex'
import { useGettext } from 'vue3-gettext'
import AppBar from '../AppBar/AppBar.vue'
import { computed, defineComponent, nextTick, onMounted, ref, unref, VNodeRef, watch } from 'vue'
import ListInfo from '../FilesList/ListInfo.vue'
import Pagination from 'web-pkg/src/components/Pagination.vue'
import { useFileActions } from '../../composables/actions/files/useFileActions'
import { searchLimit } from '../../search/sdk/list'
import { Resource } from 'web-client'
import FilesViewWrapper from '../FilesViewWrapper.vue'
import SideBar from '../../components/SideBar/SideBar.vue'
import { buildShareSpaceResource, SpaceResource } from 'web-client/src/helpers'
import {
  queryItemAsString,
  useCapabilityFilesTags,
  useClientService,
  useFileListHeaderPosition,
  useRoute,
  useRouteQuery,
  useRouter,
  useStore
} from 'web-pkg/src/composables'
import { configurationManager } from 'web-pkg/src/configuration'
import { basename } from 'path'
import { onBeforeRouteLeave } from 'vue-router'
import { useTask } from 'vue-concurrency'
import { eventBus, useCapabilityFilesFullTextSearch } from 'web-pkg'
import ItemFilter from 'web-pkg/src/components/ItemFilter.vue'
import { isLocationCommonActive } from 'web-app-files/src/router'
import ItemFilterToggle from 'web-pkg/src/components/ItemFilterToggle.vue'
import { useKeyboardActions } from 'web-pkg/src/composables/keyboardActions'
import {
  useKeyboardTableNavigation,
  useKeyboardTableMouseActions,
  useKeyboardTableActions
} from 'web-app-files/src/composables/keyboardActions'

const visibilityObserver = new VisibilityObserver()

type Tag = {
  id: string
  label: string
}

export default defineComponent({
  components: {
    AppBar,
    SideBar,
    AppLoadingSpinner,
    ContextActions,
    ListInfo,
    Pagination,
    NoContentMessage,
    ResourceTable,
    FilesViewWrapper,
    ItemFilter,
    ItemFilterToggle
  },
  props: {
    searchResult: {
      type: Object,
      default: function () {
        return { totalResults: null, values: [] }
      }
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['search'],
  setup(props, { emit }) {
    const store = useStore()
    const router = useRouter()
    const route = useRoute()
    const { $gettext } = useGettext()
    const { y: fileListHeaderY } = useFileListHeaderPosition()
    const clientService = useClientService()
    const hasTags = useCapabilityFilesTags()
    const fullTextSearchEnabled = useCapabilityFilesFullTextSearch()

    const searchTermQuery = useRouteQuery('term')
    const scopeQuery = useRouteQuery('scope')
    const doUseScope = useRouteQuery('useScope')

    const resourcesView = useResourcesViewDefaults<Resource, any, any[]>()

    const keyActions = useKeyboardActions()
    useKeyboardTableNavigation(keyActions, resourcesView.paginatedResources, resourcesView.viewMode)
    useKeyboardTableMouseActions(keyActions, resourcesView.viewMode)
    useKeyboardTableActions(keyActions)

    const searchTerm = computed(() => {
      return queryItemAsString(unref(searchTermQuery))
    })

    const availableTags = ref<Tag[]>([])
    const tagFilter = ref<VNodeRef>()
    const tagParam = useRouteQuery('q_tags')
    const fullTextParam = useRouteQuery('q_fullText')

    const displayFilter = computed(() => {
      return unref(fullTextSearchEnabled) || unref(availableTags).length
    })

    const loadAvailableTagsTask = useTask(function* () {
      const {
        data: { value: tags = [] }
      } = yield clientService.graphAuthenticated.tags.getTags()
      availableTags.value = [...tags.map((t) => ({ id: t, label: t }))]
    })

    onBeforeRouteLeave(() => {
      eventBus.publish('app.search.term.clear')
    })
    const getSpace = (resource: Resource): SpaceResource => {
      if (resource.shareId) {
        return buildShareSpaceResource({
          shareId: resource.shareId,
          shareName: basename(resource.shareRoot),
          serverUrl: configurationManager.serverUrl
        })
      }
      return store.getters['runtime/spaces/spaces'].find((space) => space.id === resource.storageId)
    }

    const buildSearchTerm = (manuallyUpdateFilterChip = false) => {
      let term = ''
      if (unref(searchTerm)) {
        term = `+Name:*${unref(searchTerm)}*`
      }

      const fullTextQuery = queryItemAsString(unref(fullTextParam))
      if (fullTextQuery) {
        term = `+Content:"${unref(searchTerm)}"`
      }
      if (unref(scopeQuery) && unref(doUseScope) === 'true') {
        term += ` scope:${unref(scopeQuery)}`
      }

      const tagsQuery = queryItemAsString(unref(tagParam))
      if (tagsQuery) {
        tagsQuery.split('+')?.forEach((tag) => {
          term += ` +Tags:"${unref(tag)}"`
        })

        if (manuallyUpdateFilterChip && unref(tagFilter)) {
          /**
           * Handles edge cases where a filter is not being applied via the filter directly,
           * e.g. when clicking on a tag in the files list.
           * We need to manually update the selected items in the ItemFilter component because normally
           * it only does this on mount or when interacting with the filter directly.
           */
          ;(unref(tagFilter) as any).setSelectedItemsBasedOnQuery()
        }
      }

      return term.trimStart()
    }

    const breadcrumbs = computed(() => {
      return [
        {
          text: unref(searchTerm)
            ? $gettext('Search results for "%{searchTerm}"', { searchTerm: unref(searchTerm) })
            : $gettext('Search')
        }
      ]
    })

    onMounted(async () => {
      if (unref(hasTags)) {
        await loadAvailableTagsTask.perform()
      }
      emit('search', buildSearchTerm())
    })

    watch(
      () => unref(route).query,
      (newVal, oldVal) => {
        const filters = ['q_fullText', 'q_tags', 'useScope']
        const isChange =
          newVal?.term !== oldVal?.term ||
          filters.some((f) => newVal[f] ?? undefined !== oldVal[f] ?? undefined)
        if (isChange && isLocationCommonActive(router, 'files-common-search')) {
          emit('search', buildSearchTerm(true))
        }
      },
      { deep: true }
    )

    return {
      ...useFileActions({ store }),
      ...resourcesView,
      loadAvailableTagsTask,
      fileListHeaderY,
      fullTextSearchEnabled,
      getSpace,
      availableTags,
      tagFilter,
      breadcrumbs,
      displayFilter
    }
  },
  computed: {
    ...mapGetters(['configuration']),
    ...mapGetters('Files', ['totalFilesCount', 'totalFilesSize']),
    displayThumbnails() {
      return !this.configuration?.options?.disablePreviews
    },
    itemCount() {
      return this.totalFilesCount.files + this.totalFilesCount.folders
    },
    rangeSupported() {
      return this.searchResult.totalResults
    },
    searchResultExceedsLimit() {
      return (
        !this.rangeSupported ||
        (this.searchResult.totalResults && this.searchResult.totalResults > searchLimit)
      )
    },
    searchResultExceedsLimitText() {
      if (!this.rangeSupported) {
        return this.$gettext('Showing up to %{searchLimit} results', {
          searchLimit: searchLimit.toString()
        })
      }

      return this.$gettext(
        'Found %{totalResults}, showing the %{itemCount} best matching results',
        {
          itemCount: this.itemCount,
          totalResults: this.searchResult.totalResults
        }
      )
    }
  },
  watch: {
    searchResult: {
      handler: async function () {
        if (!this.searchResult) {
          return
        }

        this.CLEAR_CURRENT_FILES_LIST()
        this.LOAD_FILES({
          currentFolder: null,
          files: this.searchResult.values.length
            ? this.searchResult.values.map((searchResult) => searchResult.data)
            : []
        })
        await nextTick()
        this.scrollToResourceFromRoute(this.paginatedResources)
      }
    }
  },
  beforeUnmount() {
    visibilityObserver.disconnect()
  },
  methods: {
    ...mapMutations('Files', ['CLEAR_CURRENT_FILES_LIST', 'LOAD_FILES']),
    ...mapActions('Files', ['loadPreview']),
    rowMounted(resource, component) {
      if (!this.displayThumbnails) {
        return
      }

      const debounced = debounce(({ unobserve }) => {
        unobserve()
        this.loadPreview({
          previewService: this.$previewService,
          space: this.getSpace(resource),
          resource,
          dimensions: ImageDimension.Thumbnail,
          type: ImageType.Thumbnail
        })
      }, 250)

      visibilityObserver.observe(component.$el, { onEnter: debounced, onExit: debounced.cancel })
    }
  }
})
</script>
<style lang="scss">
.files-search-resource-highlights {
  font-size: 0.8125rem;
  color: var(--oc-color-text-muted);

  mark {
    background: #fff74c;
    font-style: normal;
    font-weight: var(--oc-font-weight-semibold);
  }
}
</style>
