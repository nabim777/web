<template>
  <div
    class="oc-filter-chip oc-flex"
    :class="{ 'oc-filter-chip-toggle': isToggle, 'oc-filter-chip-raw': raw }"
  >
    <oc-button
      :id="id"
      class="oc-filter-chip-button oc-pill"
      :class="{ 'oc-filter-chip-button-selected': filterActive }"
      appearance="raw"
      @click="isToggle ? $emit('toggleFilter') : false"
    >
      <oc-icon v-if="filterActive" name="check" size="small" color="var(--oc-color-text-inverse)" />
      <span
        class="oc-text-truncate oc-filter-chip-label"
        v-text="!!selectedItemNames.length ? selectedItemNames[0] : filterLabel"
      />
      <span v-if="selectedItemNames.length > 1" v-text="` +${selectedItemNames.length - 1}`" />
      <oc-icon v-if="!filterActive && !isToggle" name="arrow-down-s" size="small" />
    </oc-button>
    <oc-drop
      v-if="!isToggle"
      :toggle="'#' + id"
      class="oc-filter-chip-drop"
      mode="click"
      padding-size="small"
      :close-on-click="closeOnClick"
      @hide-drop="$emit('hideDrop')"
      @show-drop="$emit('showDrop')"
    >
      <slot />
    </oc-drop>
    <oc-button
      v-if="filterActive"
      v-oc-tooltip="$gettext('Clear filter')"
      class="oc-filter-chip-clear oc-px-xs"
      appearance="raw"
      @click="$emit('clearFilter')"
    >
      <oc-icon name="close" size="small" color="var(--oc-color-text-inverse)" />
    </oc-button>
  </div>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import uniqueId from '../../utils/uniqueId'

export default defineComponent({
  name: 'OcFilterChip',
  status: 'ready',
  release: '15.0.0',
  props: {
    id: {
      type: String,
      required: false,
      default: () => uniqueId('oc-filter-chip-')
    },
    /**
     * Label which is displayed when no items are selected.
     */
    filterLabel: {
      type: String,
      required: true
    },
    /**
     * An array of selected item names. It is being ignored when `isToggle` is set to `true`.
     */
    selectedItemNames: {
      type: Array,
      required: false,
      default: () => []
    },
    /**
     * Display the filter chip as a on/off toggle.
     */
    isToggle: {
      type: Boolean,
      default: false
    },
    /**
     * Whether the toggle filter is active. It only has an effect if `isToggle` is set to `true`.
     */
    isToggleActive: {
      type: Boolean,
      default: false
    },
    /**
     * Whether the filter chip should be displayed as a raw button.
     */
    raw: {
      type: Boolean,
      default: false
    },
    /**
     * Whether the drop should be closed when clicking on an item.
     */
    closeOnClick: {
      type: Boolean,
      default: false
    }
  },
  emits: ['clearFilter', 'hideDrop', 'showDrop', 'toggleFilter'],
  setup(props) {
    const filterActive = computed(() => {
      if (props.isToggle) {
        return props.isToggleActive
      }
      return !!props.selectedItemNames.length
    })
    return { filterActive }
  }
})
</script>

<style lang="scss">
.oc-filter-chip {
  &-button.oc-pill {
    align-items: center;
    background-color: var(--oc-color-background-default) !important;
    color: var(--oc-color-text-muted) !important;
    border: 1px solid var(--oc-color-text-muted);
    box-sizing: border-box;
    display: inline-flex;
    gap: var(--oc-space-xsmall);
    text-decoration: none;
    font-size: var(--oc-font-size-xsmall);
    line-height: 1rem;
    max-width: 150px;
    height: 24px;
    padding: var(--oc-space-xsmall) var(--oc-space-small) !important;
  }
  &-button-selected.oc-pill,
  &-button-selected.oc-pill:hover {
    background-color: var(--oc-color-swatch-primary-default) !important;
    color: var(--oc-color-text-inverse) !important;
    border-top-left-radius: 99px !important;
    border-bottom-left-radius: 99px !important;
    border-top-right-radius: 0px !important;
    border-bottom-right-radius: 0px !important;
    border: 0;
  }
  &-clear,
  &-clear:hover {
    background-color: var(--oc-color-swatch-primary-default) !important;
    color: var(--oc-color-text-inverse) !important;
    border-top-left-radius: 0px !important;
    border-bottom-left-radius: 0px !important;
    border-top-right-radius: 99px !important;
    border-bottom-right-radius: 99px !important;
  }
  &-clear:not(.oc-filter-chip-toggle .oc-filter-chip-clear),
  &-clear:hover:not(.oc-filter-chip-toggle .oc-filter-chip-clear) {
    margin-left: 1px;
  }
}
.oc-filter-chip-raw {
  .oc-filter-chip-button {
    background-color: transparent !important;
    border: none !important;
  }
}
</style>
