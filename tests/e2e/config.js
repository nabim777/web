const withHttp = (url) => (/^https?:\/\//i.test(url) ? url : `https://${url}`)

exports.config = {
  // environment
  assets: './tests/e2e/filesForUpload',
  tempAssetsPath: './tests/e2e/filesForUpload/temp',
  baseUrlOcis: process.env.BASE_URL_OCIS ?? 'host.docker.internal:9200',
  // keycloak config
  keycloak: process.env.KEYCLOAK === 'true',
  keycloakHost: process.env.KEYCLOAK_HOST ?? 'keycloak.owncloud.test',
  keycloakRealm: process.env.KEYCLOAK_REALM ?? 'oCIS',
  keycloakAdminUser: process.env.KEYCLOAK_ADMIN_USER ?? 'admin',
  keycloakAdminPassword: process.env.KEYCLOAK_ADMIN_PASSWORD ?? 'admin',
  // do API requests with access token instead of basic auth
  apiToken: process.env.API_TOKEN === 'true' || process.env.KEYCLOAK === 'true',
  get backendUrl() {
    return withHttp(process.env.BACKEND_HOST || this.baseUrlOcis)
  },
  get frontendUrl() {
    return withHttp(process.env.SERVER_HOST || this.baseUrlOcis)
  },
  get keycloakUrl() {
    return withHttp(this.keycloakHost)
  },
  get keycloakLoginUrl() {
    return withHttp(this.keycloakHost + '/admin/master/console')
  },
  debug: process.env.DEBUG === 'true',
  logLevel: process.env.LOG_LEVEL || 'silent',
  // cucumber
  retry: process.env.RETRY || 0,
  // playwright
  slowMo: parseInt(process.env.SLOW_MO) || 0,
  timeout: parseInt(process.env.TIMEOUT) || 60,
  headless: process.env.HEADLESS === 'true',
  acceptDownloads: process.env.DOWNLOADS !== 'false',
  browser: process.env.BROWSER ?? 'chrome',
  reportDir: process.env.REPORT_DIR || 'reports/e2e',
  reportVideo: process.env.REPORT_VIDEO === 'true',
  reportHar: process.env.REPORT_HAR === 'true',
  reportTracing: process.env.REPORT_TRACING === 'true'
}
