import { themeNameLight } from './useDefaultThemeName'
import { computed, unref, Ref } from 'vue'

export const useLightTheme = ({ currentThemeName }: { currentThemeName: Ref<string> }) => {
  return {
    isLightTheme: computed(() => {
      return [null, themeNameLight].includes(unref(currentThemeName))
    })
  }
}
