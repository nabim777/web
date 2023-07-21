<template>
  <oc-button
    v-oc-tooltip="buttonLabel"
    class="themeswitcher-btn"
    :aria-label="buttonLabel"
    appearance="raw-inverse"
    variation="brand"
    @click="toggleTheme"
  >
    <span class="oc-visible@s" :aria-label="switchLabel" />
    <oc-icon :name="switchIcon" fill-type="line" variation="inherit" />
  </oc-button>
</template>
<script lang="ts">
import { computed, unref, watch, defineComponent } from 'vue'
import { useGettext } from 'vue3-gettext'
import { useStore } from 'web-pkg/src/composables'
import {
  useCurrentThemeName,
  themeNameDark,
  themeNameLight,
  useLightTheme
} from 'web-pkg/src/composables/theme'

export default defineComponent({
  setup() {
    const store = useStore()
    const currentThemeName = useCurrentThemeName()
    const currentTheme = computed(() => store.getters.configuration.themes[unref(currentThemeName)])
    const { isLightTheme } = useLightTheme({ currentThemeName })
    const { $gettext } = useGettext()
    const applyTheme = (theme) => {
      for (const param in theme.designTokens.colorPalette) {
        ;(document.querySelector(':root') as HTMLElement).style.setProperty(
          `--oc-color-${param}`,
          theme.designTokens.colorPalette[param]
        )
      }
    }

    watch(currentThemeName, async () => {
      await store.dispatch('loadTheme', { theme: unref(currentTheme) })
      applyTheme(unref(currentTheme))
    })

    const toggleTheme = () => {
      currentThemeName.value = unref(isLightTheme) ? themeNameDark : themeNameLight
    }

    const buttonLabel = computed(() => {
      return $gettext('Click to switch theme')
    })

    const switchIcon = computed(() => {
      return unref(isLightTheme) ? 'sun' : 'moon-clear'
    })

    const switchLabel = computed(() => {
      return $gettext('Currently used theme')
    })

    return {
      toggleTheme,
      buttonLabel,
      switchIcon,
      switchLabel
    }
  }
})
</script>
