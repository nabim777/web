<template>
  <nav :id="id" :class="`oc-breadcrumb oc-breadcrumb-${variation}`">
    <ol class="oc-breadcrumb-list oc-flex oc-m-rm oc-p-rm">
      <li
        v-for="(item, index) in displayItems"
        :key="index"
        :data-key="index"
        :data-item-id="item.id"
        :aria-hidden="item.isTruncationPlaceholder"
        :class="[
          'oc-breadcrumb-list-item',
          'oc-flex',
          'oc-flex-middle',
          {
            'oc-invisible-sr':
              hiddenItems.indexOf(item) !== -1 ||
              (item.isTruncationPlaceholder && hiddenItems.length === 0)
          }
        ]"
        @dragover.prevent
        @dragenter.prevent="dropItemStyling(item, index, false, $event)"
        @dragleave.prevent="dropItemStyling(item, index, true, $event)"
        @mouseleave="dropItemStyling(item, index, true, $event)"
        @drop="dropItemEvent(item, index)"
      >
        <router-link
          v-if="item.to"
          :aria-current="getAriaCurrent(index)"
          :to="item.isTruncationPlaceholder ? lastHiddenItem.to : item.to"
        >
          <span class="oc-breadcrumb-item-text">{{ item.text }}</span>
        </router-link>
        <oc-icon
          v-if="item.to"
          color="var(--oc-color-text-default)"
          name="arrow-right-s"
          class="oc-mx-xs"
          fill-type="line"
        />
        <oc-button
          v-else-if="item.onClick"
          :aria-current="getAriaCurrent(index)"
          appearance="raw"
          class="oc-flex"
          @click="item.onClick"
        >
          <span
            :class="[
              'oc-breadcrumb-item-text',
              {
                'oc-breadcrumb-item-text-last': index === displayItems.length - 1
              }
            ]"
            v-text="item.text"
          />
        </oc-button>
        <span
          v-else
          class="oc-breadcrumb-item-text"
          :aria-current="getAriaCurrent(index)"
          tabindex="-1"
          v-text="item.text"
        />
        <template v-if="showContextActions && index === displayItems.length - 1">
          <oc-button
            id="oc-breadcrumb-contextmenu-trigger"
            v-oc-tooltip="contextMenuLabel"
            :aria-label="contextMenuLabel"
            appearance="raw"
          >
            <oc-icon name="more-2" color="var(--oc-color-text-default)" />
          </oc-button>
          <oc-drop
            drop-id="oc-breadcrumb-contextmenu"
            toggle="#oc-breadcrumb-contextmenu-trigger"
            mode="click"
            close-on-click
            :padding-size="contextMenuPadding"
          >
            <!-- @slot Add context actions that open in a dropdown when clicking on the "three dots" button -->
            <slot name="contextMenu" />
          </oc-drop>
        </template>
      </li>
    </ol>
    <oc-button
      v-if="displayItems.length > 1"
      appearance="raw"
      type="router-link"
      :aria-label="$gettext('Navigate one level up')"
      :to="parentFolderTo"
      class="oc-breadcrumb-mobile-navigation"
    >
      <oc-icon name="arrow-left-s" fill-type="line" size="large" class="oc-mr-m" />
    </oc-button>
  </nav>
  <div v-if="displayItems.length > 1" class="oc-breadcrumb-mobile-current">
    <span class="oc-text-truncate" aria-current="page" v-text="currentFolder.text" />
  </div>
</template>

<script lang="ts">
import { computed, defineComponent, nextTick, PropType, ref, unref, watch } from 'vue'
import { useGettext } from 'vue3-gettext'

import { AVAILABLE_SIZES, EVENT_ITEM_DROPPED_BREADCRUMB } from '../../helpers/constants'

import OcButton from '../OcButton/OcButton.vue'
import OcDrop from '../OcDrop/OcDrop.vue'
import OcIcon from '../OcIcon/OcIcon.vue'
import uniqueId from '../../utils/uniqueId'

import { BreadcrumbItem } from './types'

/**
 * Displays a breadcrumb. Each item in the items property has the following elements:
 *
 *  - text: mandatory element, holds the text which is to be displayed in the breadcrumb
 *  - to: optional element, the vue router link
 */
export default defineComponent({
  name: 'OcBreadcrumb',
  status: 'ready',
  release: '1.0.0',

  components: {
    OcDrop,
    OcIcon,
    OcButton
  },
  props: {
    /**
     * Id for the breadcrumbs. If it's empty, a generated one will be used.
     */
    id: {
      type: String,
      required: false,
      default: () => uniqueId('oc-breadcrumbs-')
    },
    /**
     * Array of breadcrumb items
     */
    items: {
      type: Array as PropType<BreadcrumbItem[]>,
      required: true
    },
    /**
     * Variation of breadcrumbs
     * Can be `default` or `lead`
     */
    variation: {
      type: String,
      required: false,
      default: 'default',
      validator: (value) => value === 'lead' || value === 'default'
    },
    /**
     * Defines the padding size around the drop content. Defaults to `medium`.
     *
     * @values xsmall, small, medium, large, xlarge, xxlarge, xxxlarge, remove
     */
    contextMenuPadding: {
      type: String,
      required: false,
      default: 'medium',
      validator: (value) => {
        return [...AVAILABLE_SIZES, 'remove'].some((e) => e === value)
      }
    },

    /**
     * Defines the maximum width of the breadcrumb. If the breadcrumb is wider than the given value, the breadcrumb
     * will be reduced from the left side.
     * If the value is -1, the breadcrumb will not be reduced.
     */
    maxWidth: {
      type: Number,
      required: false,
      default: -1
    },
    /**
     * Defines the number of items that should be always displayed at the beginning of the breadcrumb.
     * The default value is 2. e.g. Personal > ... > XYZ
     */
    truncationOffset: {
      type: Number,
      required: false,
      default: 2
    },
    /**
     * Determines if the last breadcrumb item should have context menu actions.
     */
    showContextActions: {
      type: Boolean,
      default: false
    }
  },
  emits: [EVENT_ITEM_DROPPED_BREADCRUMB],
  setup(props, { emit }) {
    const { $gettext } = useGettext()
    const visibleItems = ref<BreadcrumbItem[]>([])
    const hiddenItems = ref<BreadcrumbItem[]>([])
    const displayItems = ref<BreadcrumbItem[]>(props.items.slice())

    const getBreadcrumbElement = (id): HTMLElement => {
      return document.querySelector(`.oc-breadcrumb-list [data-item-id="${id}"]`)
    }

    const isDropAllowed = (item: BreadcrumbItem, index: number): boolean => {
      return !(
        !item.id ||
        index === unref(displayItems).length - 1 ||
        item.isTruncationPlaceholder ||
        item.isStaticNav
      )
    }
    const dropItemEvent = (item, index) => {
      if (!isDropAllowed(item, index)) {
        return
      }
      item.to.path = item.to.path || '/'
      emit(EVENT_ITEM_DROPPED_BREADCRUMB, item.to)
    }

    const calculateTotalBreadcrumbWidth = () => {
      let totalBreadcrumbWidth = 100 // 100px margin to the right to avoid breadcrumb from getting too close to the controls
      visibleItems.value.forEach((item) => {
        const breadcrumbElement = getBreadcrumbElement(item.id)
        const itemClientWidth = breadcrumbElement?.getBoundingClientRect()?.width || 0
        totalBreadcrumbWidth += itemClientWidth
      })
      return totalBreadcrumbWidth
    }

    const reduceBreadcrumb = (offsetIndex) => {
      const breadcrumbMaxWidth = props.maxWidth
      if (!breadcrumbMaxWidth) {
        return
      }
      const totalBreadcrumbWidth = calculateTotalBreadcrumbWidth()

      const isOverflowing = breadcrumbMaxWidth < totalBreadcrumbWidth
      if (!isOverflowing || visibleItems.value.length <= props.truncationOffset + 1) {
        return
      }
      // Remove from the left side
      const removed = visibleItems.value.splice(offsetIndex, 1)

      hiddenItems.value.push(removed[0])
      reduceBreadcrumb(offsetIndex)
    }

    const lastHiddenItem = computed(() =>
      hiddenItems.value.length >= 1 ? unref(hiddenItems)[unref(hiddenItems).length - 1] : { to: {} }
    )

    const renderBreadcrumb = () => {
      displayItems.value = [...props.items]
      if (displayItems.value.length > props.truncationOffset - 1) {
        displayItems.value.splice(props.truncationOffset - 1, 0, {
          text: '...',
          allowContextActions: false,
          to: {},
          isTruncationPlaceholder: true
        })
      }
      visibleItems.value = [...displayItems.value]
      hiddenItems.value = []
      nextTick(() => {
        reduceBreadcrumb(props.truncationOffset)
      })
    }

    watch([() => props.maxWidth, () => props.items], renderBreadcrumb, { immediate: true })

    const currentFolder = computed<BreadcrumbItem>(() => {
      if (props.items.length === 0 || !props.items) {
        return undefined
      }
      return [...props.items].reverse()[0]
    })
    const parentFolderTo = computed(() => {
      return [...props.items].reverse()[1].to
    })

    const contextMenuLabel = computed(() => {
      return $gettext('Show actions for current folder')
    })

    const getAriaCurrent = (index): 'page' | null => {
      return props.items.length - 1 === index ? 'page' : null
    }

    const dropItemStyling = (item: BreadcrumbItem, index: number, leaving: boolean, event) => {
      if (!isDropAllowed(item, index)) {
        return
      }
      const hasFilePayload = (event.dataTransfer?.types || []).some((e) => e === 'Files')
      if (hasFilePayload) return
      if (event.currentTarget?.contains(event.relatedTarget)) {
        return
      }

      const classList = getBreadcrumbElement(item.id).children[0].classList
      const className = 'oc-breadcrumb-item-dragover'
      leaving ? classList.remove(className) : classList.add(className)
    }

    return {
      currentFolder,
      parentFolderTo,
      contextMenuLabel,
      getAriaCurrent,
      visibleItems,
      hiddenItems,
      renderBreadcrumb,
      displayItems,
      lastHiddenItem,
      dropItemEvent,
      dropItemStyling
    }
  }
})
</script>

<style lang="scss">
.oc-breadcrumb {
  overflow: visible;
  &-item-dragover {
    transition: background 0.06s, border 0s 0.08s, border-color 0s, border-width 0.06s;
    background-color: var(--oc-color-background-highlight);
    box-shadow: 0 0 0 5px var(--oc-color-background-highlight);
    border-radius: 5px;
  }
  &-item-text {
    max-width: 200px;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;

    &-last {
      vertical-align: text-bottom;
    }
  }

  &-mobile-current,
  &-mobile-navigation {
    @media (min-width: $oc-breakpoint-small-default) {
      display: none !important;
    }
  }

  &-list {
    @media (max-width: $oc-breakpoint-xsmall-max) {
      display: none !important;
    }

    list-style: none;
    align-items: baseline;
    flex-wrap: nowrap;

    #oc-breadcrumb-contextmenu-trigger > span {
      vertical-align: middle;
      border: 3px solid transparent;
    }

    #oc-breadcrumb-contextmenu li button {
      display: inline-flex;
    }

    > li button {
      display: inline;
    }

    > :nth-child(n + 2)::before {
      color: var(--oc-color-text-default);
      display: inline-block;
    }

    > :last-child > span {
      color: var(--oc-color-text-default);
    }

    > li a:hover,
    > li span:not([aria-current='page']):not(.oc-icon):hover,
    > li button:hover {
      text-decoration: underline;
    }
  }

  /* stylelint-disable */
  &-list-item {
    a:first-of-type,
    button:first-of-type,
    span:first-of-type {
      font-size: var(--oc-font-size-medium);
      color: var(--oc-color-text-default);
      display: inline-block;
      vertical-align: sub;
      line-height: normal;
    }
  }

  &-lead &-list-item {
    a,
    button,
    span {
      font-size: var(--oc-font-size-large);
    }
  }
}
</style>

<docs>
```js
<template>
<section>
  <div>
    <oc-breadcrumb :items="items" />
  </div>
  <div>
    <oc-breadcrumb :items="items" variation="lead" />
    <oc-breadcrumb :items="items" >
      <template v-slot:contextMenu>
        <p class="oc-my-rm">I'm an example item</p>
      </template>
    </oc-breadcrumb>
  </div>
</section>
</template>
<script>
  export default {
    data: () => {
      return {
        items: [
          {text:'First folder',to:{path:'folder'}},
          {text:'Subfolder', to: {path: 'subfolder'}},
          {text:'Deep',to:{path:'deep'}},
          {text:'Deeper ellipsize in responsive mode'},
        ]
      }
    }
  }
</script>
```
</docs>
