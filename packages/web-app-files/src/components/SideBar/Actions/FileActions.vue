<template>
  <oc-list id="oc-files-actions-sidebar" class="oc-mt-s">
    <action-menu-item
      v-for="(action, index) in actions"
      :key="`action-${index}`"
      :action="action"
      :action-options="{ space, resources }"
      class="oc-rounded"
    />
  </oc-list>
</template>

<script lang="ts">
import ActionMenuItem from 'web-pkg/src/components/ContextActions/ActionMenuItem.vue'
import { useFileActions } from '../../../composables/actions/files/useFileActions'
import { computed, defineComponent, inject, Ref, unref } from 'vue'
import { Resource, SpaceResource } from 'web-client'

export default defineComponent({
  name: 'FileActions',
  components: {
    ActionMenuItem
  },
  setup() {
    const resource = inject<Resource>('resource')
    const space = inject<Ref<SpaceResource>>('space')
    const resources = computed(() => {
      return [unref(resource)]
    })
    const { getAllAvailableActions } = useFileActions()
    const actions = computed(() => {
      return getAllAvailableActions({
        space: unref(space),
        resources: unref(resources)
      })
    })

    return {
      space,
      resources,
      actions
    }
  }
})
</script>

<style lang="scss">
#oc-files-actions-sidebar {
  > li a,
  > li a:hover {
    color: var(--oc-color-swatch-passive-default);
    display: inline-flex;
    gap: 10px;
    vertical-align: top;
  }

  > li:hover {
    text-decoration: none !important;
    background-color: var(--oc-color-background-hover);
  }
}
</style>
