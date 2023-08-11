import { eventBus } from 'web-pkg/src/services/eventBus'
import { computed, Ref, unref } from 'vue'
import { useGettext } from 'vue3-gettext'
import { UserAction } from 'web-pkg/src/composables/actions'
import { useCapabilityReadOnlyUserAttributes } from 'web-pkg'

export const useUserActionsRemoveFromGroups = (): { actions: Ref<UserAction[]> } => {
  const { $gettext } = useGettext()
  const readOnlyUserAttributes = useCapabilityReadOnlyUserAttributes()

  const actions = computed((): UserAction[] => [
    {
      name: 'remove-users-from-groups',
      icon: 'subtract',
      componentType: 'button',
      class: 'oc-users-actions-remove-from-groups-trigger',
      label: () => $gettext('Remove from groups'),
      isEnabled: ({ resources }) => {
        if (unref(readOnlyUserAttributes).includes('user.accountEnabled')) {
          return false
        }

        return resources.length > 0
      },
      handler() {
        eventBus.publish('app.admin-settings.users.actions.remove-from-groups')
      }
    }
  ])

  return {
    actions
  }
}
