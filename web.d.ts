/// <reference types="vite/client" />

declare module 'vue' {
  import { CompatVue } from '@vue/runtime-dom'
  const Vue: CompatVue
  export default Vue
  export * from '@vue/runtime-dom'
  const { configureCompat } = Vue
  export { configureCompat }

  export interface GlobalComponents {
    Portal: typeof import('portal-vue')['Portal']
    PortalTarget: typeof import('portal-vue')['PortalTarget']
  }
}
declare module '*.vue' {
  import Vue from 'vue'
  export default Vue
}
