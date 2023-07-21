import { useLocalStorage } from '../localStorage'
import { useDefaultThemeName } from './useDefaultThemeName'

export const useCurrentThemeName = () => {
  return useLocalStorage('oc_currentThemeName', useDefaultThemeName())
}
