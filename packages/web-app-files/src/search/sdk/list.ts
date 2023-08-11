import { SearchList, SearchResult } from 'web-app-search/src/types'
import ListComponent from '../../components/Search/List.vue'
import { ClientService } from 'web-pkg/src/services'
import {
  ProjectSpaceResource,
  buildResource,
  isProjectSpaceResource,
  Resource
} from 'web-client/src/helpers'
import { Component, computed, Ref, unref } from 'vue'
import { DavProperties, DavProperty } from 'web-client/src/webdav/constants'
import { Store } from 'vuex'

export const searchLimit = 200

export interface SearchResource extends Resource {
  highlights: string
}

export default class List implements SearchList {
  public readonly component: Component
  private readonly store: Store<any>
  private readonly clientService: ClientService
  private readonly projectSpaces: Ref<ProjectSpaceResource[]>

  constructor(store: Store<any>, clientService: ClientService) {
    this.component = ListComponent
    this.store = store
    this.clientService = clientService
    this.projectSpaces = computed(() =>
      this.store.getters['runtime/spaces/spaces'].filter((s) => isProjectSpaceResource(s))
    )
  }

  getMatchingSpace(id: string): ProjectSpaceResource {
    return unref(this.projectSpaces).find((s) => s.id === id)
  }

  async search(term: string): Promise<SearchResult> {
    const useSpacesEndpoint = this.store.getters.capabilities?.spaces?.enabled === true

    if (!term) {
      return {
        totalResults: null,
        values: []
      }
    }

    await this.store.dispatch('runtime/spaces/loadMountPoints', {
      graphClient: this.clientService.graphAuthenticated
    })

    const { range, results } = await this.clientService.owncloudSdk.files.search(
      term,
      searchLimit,
      DavProperties.Default,
      useSpacesEndpoint
    )

    return {
      totalResults: range ? parseInt(range?.split('/')[1]) : null,
      values: results.map((result) => {
        const matchingSpace = this.getMatchingSpace(result.fileInfo[DavProperty.FileParent])
        const resource = {
          ...(matchingSpace ? matchingSpace : buildResource(result)),
          highlights: result.fileInfo[DavProperty.Highlights] || ''
        } as SearchResource

        // info: in oc10 we have no storageId in resources. All resources are mounted into the personal space.
        if (!resource.storageId) {
          resource.storageId = this.store.getters.user.id
        }
        return { id: resource.id, data: resource }
      })
    }
  }
}
