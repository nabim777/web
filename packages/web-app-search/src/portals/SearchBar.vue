<template>
  <div
    v-if="isSearchBarEnabled"
    id="files-global-search"
    ref="searchBar"
    class="oc-flex"
    data-custom-key-bindings-disabled="true"
  >
    <oc-search-bar
      id="files-global-search-bar"
      ref="search"
      :label="searchLabel"
      :type-ahead="true"
      :value="term"
      :placeholder="searchLabel"
      :button-hidden="true"
      :show-cancel-button="showCancelButton"
      cancel-button-variation="brand"
      cancel-button-appearance="raw-inverse"
      :cancel-handler="cancelSearch"
      @advanced-search="onKeyUpEnter"
      @input="updateTerm"
      @clear="onClear"
      @click="showPreview"
      @keyup.esc="hideOptionsDrop"
      @keyup.up="onKeyUpUp"
      @keyup.down="onKeyUpDown"
      @keyup.enter="onKeyUpEnter"
    >
      <template #locationFilter>
        <search-bar-filter
          :current-folder-available="currentFolderAvailable"
          @update:model-value="onLocationFilterChange"
        />
      </template>
    </oc-search-bar>
    <oc-button
      v-oc-tooltip="$gettext('Display search bar')"
      :aria-label="$gettext('Click to display and focus the search bar')"
      class="mobile-search-btn oc-mr-l"
      appearance="raw-inverse"
      variation="brand"
      @click="showSearchBar"
    >
      <oc-icon name="search" fill-type="line"></oc-icon>
    </oc-button>
    <oc-drop
      id="files-global-search-options"
      ref="optionsDropRef"
      mode="manual"
      target="#files-global-search-bar"
    >
      <oc-list class="oc-list-divider">
        <li
          v-if="loading"
          class="loading spinner oc-flex oc-flex-center oc-flex-middle oc-text-muted"
        >
          <oc-spinner size="small" :aria-hidden="true" aria-label="" />
          <span class="oc-ml-s">{{ $gettext('Searching ...') }}</span>
        </li>
        <li v-else-if="showNoResults" id="no-results" class="oc-flex oc-flex-center">
          {{ $gettext('No results') }}
        </li>
        <template v-else>
          <li v-for="provider in displayProviders" :key="provider.id" class="provider">
            <oc-list>
              <li class="oc-text-truncate oc-flex oc-flex-between oc-text-muted provider-details">
                <span class="display-name" v-text="$gettext(provider.displayName)" />
                <span v-if="!!provider.listSearch">
                  <router-link
                    class="more-results"
                    :to="getMoreResultsLinkForProvider(provider)"
                    @click="hideOptionsDrop"
                  >
                    <span>{{ getMoreResultsDetailsTextForProvider(provider) }}</span>
                  </router-link>
                </span>
              </li>
              <li
                v-for="providerSearchResultValue in getSearchResultForProvider(provider).values"
                :key="providerSearchResultValue.id"
                :data-search-id="providerSearchResultValue.id"
                :class="{
                  active: isPreviewElementActive(providerSearchResultValue.id)
                }"
                class="preview oc-flex oc-flex-middle"
              >
                <component
                  :is="provider.previewSearch.component"
                  class="preview-component"
                  :provider="provider"
                  :search-result="providerSearchResultValue"
                  @click="hideOptionsDrop"
                />
              </li>
            </oc-list>
          </li>
        </template>
      </oc-list>
    </oc-drop>
  </div>
  <div v-else><!-- no search provider available --></div>
</template>

<script lang="ts">
import { providerStore } from '../service'
import {
  createLocationCommon,
  isLocationCommonActive,
  isLocationSpacesActive
} from 'web-app-files/src/router'
import Mark from 'mark.js'
import { debounce } from 'lodash-es'
import { useRouteQuery, useRouter, useStore, useUserContext } from 'web-pkg/src/composables'
import { eventBus } from 'web-pkg/src/services/eventBus'
import { computed, defineComponent, GlobalComponents, inject, Ref, ref, unref, watch } from 'vue'
import { SearchLocationFilterConstants } from 'web-pkg/src/composables'
import { SearchBarFilter } from 'web-pkg/src/components'
import { SHARE_JAIL_ID } from 'web-client/src/helpers'

export default defineComponent({
  name: 'SearchBar',
  components: { SearchBarFilter },
  setup() {
    const store = useStore()
    const router = useRouter()
    const showCancelButton = ref(false)
    const isMobileWidth = inject<Ref<boolean>>('isMobileWidth')
    const scopeQueryValue = useRouteQuery('scope')
    const shareId = useRouteQuery('shareId')
    const locationFilterId = ref(SearchLocationFilterConstants.currentFolder)
    const optionsDropRef = ref(null)
    const activePreviewIndex = ref(null)
    const term = ref('')
    const searchResults = ref([])
    const loading = ref(false)
    const currentFolderAvailable = ref(false)

    watch(isMobileWidth, () => {
      const searchBarEl = document.getElementById('files-global-search-bar')
      const optionDropVisible = !!document.querySelector('.tippy-box[data-state="visible"]')

      if (!unref(isMobileWidth)) {
        searchBarEl.style.visibility = 'visible'
        showCancelButton.value = false
      } else {
        if (optionDropVisible) {
          searchBarEl.style.visibility = 'visible'
          showCancelButton.value = true
        } else {
          searchBarEl.style.visibility = 'hidden'
          showCancelButton.value = false
        }
      }
    })

    const isShareRoute = () => {
      return !!shareId.value
    }

    const optionsDrop = computed(() => {
      return unref(optionsDropRef) as InstanceType<GlobalComponents['OcDrop']>
    })

    const availableProviders = computed(() => {
      return unref(providerStore)?.availableProviders
    })

    const buildLocationScopeId = () => {
      const currentFolder = store.getters['Files/currentFolder']
      const path = currentFolder.path === '/' ? '' : currentFolder.path
      if (isShareRoute()) {
        return `${SHARE_JAIL_ID}$${SHARE_JAIL_ID}!${shareId.value}${path}`
      }
      const spaceId = currentFolder.fileId.split('!')[0]
      return `${spaceId}${path}`
    }

    const search = async () => {
      searchResults.value = []
      if (!unref(term)) {
        return
      }
      let searchTerm = unref(term)
      if (
        unref(currentFolderAvailable) &&
        unref(locationFilterId) === SearchLocationFilterConstants.currentFolder
      ) {
        const currentFolder = store.getters['Files/currentFolder']
        let scope
        if (currentFolder?.fileId) {
          scope = buildLocationScopeId()
        } else {
          scope = unref(scopeQueryValue)
        }
        searchTerm = `${unref(term)} scope:${scope}`
      }
      loading.value = true
      for (const availableProvider of unref(availableProviders)) {
        if (availableProvider.previewSearch?.available) {
          searchResults.value.push({
            providerId: availableProvider.id,
            result: await availableProvider.previewSearch.search(unref(searchTerm))
          })
        }
      }
      loading.value = false
    }

    const onKeyUpEnter = () => {
      if (unref(optionsDrop)) {
        unref(optionsDrop).hide()
      }

      if (unref(activePreviewIndex) === null) {
        const currentQuery = unref(router.currentRoute).query
        const currentFolder = store.getters['Files/currentFolder']
        let scope
        if (unref(currentFolderAvailable) && currentFolder?.fileId) {
          scope = buildLocationScopeId()
        } else {
          scope = unref(scopeQueryValue)
        }
        const useScope =
          unref(term) &&
          unref(currentFolderAvailable) &&
          unref(locationFilterId) === SearchLocationFilterConstants.currentFolder
        router.push(
          createLocationCommon('files-common-search', {
            query: {
              ...(currentQuery && { ...currentQuery }),
              term: unref(term),
              ...(scope && { scope }),
              useScope: useScope.toString(),
              provider: 'files.sdk'
            }
          })
        )
      }
      if (unref(activePreviewIndex) !== null) {
        unref(optionsDrop)
          .$el.querySelectorAll('.preview')
          [unref(activePreviewIndex)].firstChild.click()
      }
    }

    const onLocationFilterChange = (event) => {
      locationFilterId.value = event.value.id
      if (!unref(term)) {
        return
      }

      if (isLocationCommonActive(router, 'files-common-search')) {
        onKeyUpEnter()
        return
      }
      search()
    }

    const showPreview = async () => {
      if (!unref(term)) {
        return
      }
      unref(optionsDrop).show()
      await search()
    }

    const updateTerm = (input) => {
      term.value = input
      if (!unref(term)) {
        return unref(optionsDrop).hide()
      }
      return unref(optionsDrop).show()
    }

    return {
      isUserContext: useUserContext({ store }),
      showCancelButton,
      onLocationFilterChange,
      currentFolderAvailable,
      store,
      scopeQueryValue,
      optionsDrop,
      optionsDropRef,
      activePreviewIndex,
      term,
      onKeyUpEnter,
      searchResults,
      loading,
      providerStore,
      availableProviders,
      search,
      showPreview,
      updateTerm
    }
  },

  data() {
    return {
      activeProvider: undefined,
      optionsVisible: false,
      markInstance: null,
      debouncedSearch: undefined,
      hideOptionsDropEvent: null,
      clearTermEvent: null
    }
  },
  computed: {
    showNoResults() {
      return this.searchResults.every(({ result }) => !result.values.length)
    },

    isSearchBarEnabled() {
      return this.availableProviders.length && this.isUserContext
    },
    displayProviders() {
      /**
       * Computed to filter and sort providers that will be displayed
       * Only show providers which actually hold results
       */
      return this.availableProviders.filter(
        (provider) => this.getSearchResultForProvider(provider).values.length
      )
    },
    searchLabel() {
      return this.$gettext('Enter search term')
    }
  },

  watch: {
    term() {
      this.debouncedSearch(this)
    },
    searchResults: {
      handler() {
        this.activePreviewIndex = null

        this.$nextTick(() => {
          if (this.showNoResults) {
            return
          }
          if (this.optionsDrop) {
            this.markInstance = new Mark(this.optionsDrop.$refs.drop)
            this.markInstance.unmark()
            this.markInstance.mark(this.term, {
              element: 'span',
              className: 'highlight-mark',
              exclude: ['.provider-details *']
            })
          }
        })
      },
      deep: true
    },
    $route: {
      handler(r) {
        const currentFolderAvailable =
          (isLocationSpacesActive(this.$router, 'files-spaces-generic') ||
            !!this.scopeQueryValue) &&
          !isLocationSpacesActive(this.$router, 'files-spaces-projects')
        if (this.currentFolderAvailable !== currentFolderAvailable) {
          this.currentFolderAvailable = currentFolderAvailable
        }

        this.$nextTick(() => {
          if (!this.availableProviders.length) {
            return
          }
          const routeTerm = r?.query?.term
          const input = this.$el.getElementsByTagName('input')[0]
          if (!input || !routeTerm) {
            return
          }
          this.term = routeTerm
          input.value = routeTerm
        })
      },
      immediate: true
    }
  },
  created() {
    this.debouncedSearch = debounce(this.search, 500)

    this.clearTermEvent = eventBus.subscribe('app.search.term.clear', () => {
      this.term = ''
    })
    this.hideOptionsDropEvent = eventBus.subscribe('app.search.options-drop.hide', () => {
      this.optionsDrop.hide()
    })
  },

  beforeUnmount() {
    eventBus.unsubscribe('app.search.term.clear', this.clearTermEvent)
    eventBus.unsubscribe('app.search.options-drop.hide', this.hideOptionsDropEvent)
  },

  methods: {
    onClear() {
      this.term = ''
      this.optionsDrop.hide()
    },
    findNextPreviewIndex(previous = false) {
      const elements = Array.from(document.querySelectorAll('li.preview'))
      let index =
        this.activePreviewIndex !== null ? this.activePreviewIndex : previous ? elements.length : -1
      const increment = previous ? -1 : 1

      do {
        index += increment
        if (index < 0 || index > elements.length - 1) {
          return null
        }
      } while (elements[index].classList.contains('disabled'))

      return index
    },
    onKeyUpUp() {
      this.activePreviewIndex = this.findNextPreviewIndex(true)
      this.scrollToActivePreviewOption()
    },
    onKeyUpDown() {
      this.activePreviewIndex = this.findNextPreviewIndex(false)
      this.scrollToActivePreviewOption()
    },
    scrollToActivePreviewOption() {
      if (typeof this.optionsDrop.$el.scrollTo !== 'function') {
        return
      }

      const previewElements = this.optionsDrop.$el.querySelectorAll('.preview')

      this.optionsDrop.$el.scrollTo(
        0,
        this.activePreviewIndex === null
          ? 0
          : previewElements[this.activePreviewIndex].getBoundingClientRect().y -
              previewElements[this.activePreviewIndex].getBoundingClientRect().height
      )
    },

    getSearchResultForProvider(provider) {
      return this.searchResults.find(({ providerId }) => providerId === provider.id)?.result
    },
    getMoreResultsLinkForProvider(provider) {
      const currentQuery = unref(this.$router.currentRoute).query

      return createLocationCommon('files-common-search', {
        query: { ...(currentQuery && { ...currentQuery }), term: this.term, provider: provider.id }
      })
    },
    getMoreResultsDetailsTextForProvider(provider) {
      const searchResult = this.getSearchResultForProvider(provider)
      if (!searchResult || !searchResult.totalResults) {
        return this.$gettext('Show all results')
      }

      return this.$ngettext(
        'Show %{totalResults} result',
        'Show %{totalResults} results',
        searchResult.totalResults,
        {
          totalResults: searchResult.totalResults
        }
      )
    },
    isPreviewElementActive(searchId) {
      const previewElements = this.optionsDrop.$el.querySelectorAll('.preview')
      return previewElements[this.activePreviewIndex]?.dataset?.searchId === searchId
    },
    showSearchBar() {
      document.getElementById('files-global-search-bar').style.visibility = 'visible'
      const inputElement = document.getElementsByClassName('oc-search-input')[0] as HTMLElement
      inputElement.focus()

      this.showCancelButton = true
    },
    cancelSearch() {
      document.getElementById('files-global-search-bar').style.visibility = 'hidden'
      this.showCancelButton = false
    },
    hideOptionsDrop() {
      this.optionsDrop.hide()
    }
  }
})
</script>

<style lang="scss">
#files-global-search {
  .mobile-search-btn {
    display: none;
    @media (max-width: 639px) {
      display: inline-flex;
    }
  }

  .oc-search-input {
    background-color: var(--oc-color-input-bg);
    transition: 0s;
    height: 2.3rem;

    @media (max-width: 639px) {
      border: none;
      display: inline;
    }
  }

  #files-global-search-bar {
    width: 452px;
    @media (max-width: 959px) {
      width: 300px;
    }

    @media (max-width: 639px) {
      visibility: hidden;
      background-color: var(--oc-color-swatch-brand-default);
      position: absolute;
      height: 48px;
      left: 0;
      right: 0;
      margin: 0 auto;
      top: 0;
      width: 95vw !important;
      z-index: 9;

      .oc-search-input-icon {
        padding: 0 var(--oc-space-xlarge);
      }

      input,
      input:not(:placeholder-shown) {
        background-color: var(--oc-color-input-bg);
        border: 1px solid var(--oc-color-input-border);
        z-index: var(--oc-z-index-modal);
        margin: 0 auto;
      }
    }
  }

  #files-global-search-options {
    width: 450px;
    overflow-y: auto;
    max-height: calc(100vh - 60px);
    text-decoration: none;

    .oc-card {
      padding: 0 !important;
    }

    .highlight-mark {
      font-weight: 600;
    }

    @media (max-width: 969px) {
      width: 300px;
    }

    @media (max-width: 639px) {
      width: 93vw !important;
    }

    ul {
      li.provider-details,
      li.loading,
      li#no-results {
        padding: var(--oc-space-xsmall) var(--oc-space-small);
      }

      li {
        position: relative;
        font-size: var(--oc-font-size-small);

        &.provider-details {
          font-size: var(--oc-font-size-xsmall);
        }

        &.preview {
          min-height: 44px;
          font-size: inherit;
          padding: var(--oc-space-xsmall) var(--oc-space-small);

          &:hover,
          &.active {
            background-color: var(--oc-color-background-highlight);
          }
          &.disabled {
            background-color: var(--oc-color-background-muted);
            pointer-events: none;
            opacity: 0.7;
            filter: grayscale(0.6);
          }
        }
      }
    }
  }
}
</style>
