import {
  Before,
  BeforeAll,
  setDefaultTimeout,
  setWorldConstructor,
  ITestCaseHookParameter,
  AfterAll,
  After,
  Status
} from '@cucumber/cucumber'
import pino from 'pino'
import { Browser, chromium, firefox, webkit } from 'playwright'

import { config } from '../../config'
import { api, environment } from '../../support'
import { World } from './world'
import { state } from './shared'
import {
  createdSpaceStore,
  createdLinkStore,
  createdGroupStore,
  createdUserStore
} from '../../support/store'
import { User } from '../../support/types'
import { Session } from '../../support/objects/runtime/session'
import { createdTokenStore } from '../../support/store/token'
import { removeTempUploadDirectory } from '../../support/utils/runtimeFs'

export { World }

const usersEnvironment = new environment.UsersEnvironment()
const logger = pino({
  level: config.logLevel,
  transport: {
    target: 'pino-pretty',
    options: {
      colorize: true
    }
  }
})
setDefaultTimeout(config.debug ? -1 : config.timeout * 1000)

Before(async function (this: World, { pickle }: ITestCaseHookParameter) {
  this.feature = pickle
  this.actorsEnvironment.on('console', (actorId, message): void => {
    const msg = {
      actor: actorId,
      text: message.text(),
      type: message.type(),
      args: message.args(),
      location: message.location()
    }

    switch (message.type()) {
      case 'debug':
        logger.debug(msg)
        break
      case 'info':
        logger.info(msg)
        break
      case 'error':
        logger.error(msg)
        break
      case 'warning':
        logger.warn(msg)
        break
    }
  })
  if (config.apiToken) {
    await setAdminToken(state.browser)
  }
})

BeforeAll(async (): Promise<void> => {
  const browserConfiguration = {
    slowMo: config.slowMo,
    args: ['--use-fake-ui-for-media-stream', '--use-fake-device-for-media-stream'],
    firefoxUserPrefs: {
      'media.navigator.streams.fake': true,
      'media.navigator.permission.disabled': true
    },
    headless: config.headless
  }

  state.browser = await {
    firefox: async (): Promise<Browser> => await firefox.launch(browserConfiguration),
    webkit: async (): Promise<Browser> => await webkit.launch(browserConfiguration),
    chrome: async (): Promise<Browser> =>
      await chromium.launch({ ...browserConfiguration, channel: 'chrome' }),
    chromium: async (): Promise<Browser> => await chromium.launch(browserConfiguration)
  }[config.browser]()
})

const defaults = {
  reportHar: config.reportHar,
  reportTracing: config.reportTracing
}

After(async function (this: World, { result }: ITestCaseHookParameter) {
  if (!result) {
    return
  }

  config.reportHar = result.willBeRetried || defaults.reportHar
  config.reportTracing = result.willBeRetried || defaults.reportTracing

  if (result.status !== Status.PASSED) {
    await this.actorsEnvironment.close()
  }

  await cleanUpUser(this.usersEnvironment.getUser({ key: 'admin' }))
  await cleanUpSpaces(this.usersEnvironment.getUser({ key: 'admin' }))
  await cleanUpGroup(this.usersEnvironment.getUser({ key: 'admin' }))

  createdLinkStore.clear()
  createdTokenStore.clear()
  removeTempUploadDirectory()
})

AfterAll(() => state.browser && state.browser.close())

setWorldConstructor(World)

const cleanUpUser = async (adminUser: User) => {
  const requests = []
  createdUserStore.forEach((user) => {
    requests.push(api.graph.deleteUser({ user, admin: adminUser }))
  })
  await Promise.all(requests)
  createdUserStore.clear()
}

const cleanUpSpaces = async (adminUser: User) => {
  const requests = []
  createdSpaceStore.forEach((space) => {
    requests.push(
      api.graph
        .disableSpace({
          user: adminUser,
          space
        })
        .then(async (res) => {
          if (res.status === 204) {
            await api.graph.deleteSpace({
              user: adminUser,
              space
            })
          }
        })
    )
  })
  await Promise.all(requests)
  createdSpaceStore.clear()
}

const cleanUpGroup = async (adminUser: User) => {
  const requests = []
  createdGroupStore.forEach((group) => {
    requests.push(api.graph.deleteGroup({ group, admin: adminUser }))
  })

  await Promise.all(requests)
  createdGroupStore.clear()
}

const setAdminToken = async (browser: Browser) => {
  const ctx = await browser.newContext({ ignoreHTTPSErrors: true })
  const page = await ctx.newPage()
  const admin = usersEnvironment.getUser({ key: 'admin' })
  await page.goto(config.frontendUrl)
  await new Session({ page }).login({ user: admin })

  await page.close()
  await ctx.close()
}
