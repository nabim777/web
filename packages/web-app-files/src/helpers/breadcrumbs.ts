import { eventBus } from 'web-pkg/src/services/eventBus'
import { RouteLocation } from 'vue-router'
import { BreadcrumbItem } from 'design-system/src/components/OcBreadcrumb/types'
import { v4 as uuidv4 } from 'uuid'
import { AncestorMetaData } from 'web-app-files/src/helpers/resource'
import omit from 'lodash-es/omit'

export const breadcrumbsFromPath = (
  currentRoute: RouteLocation,
  resourcePath: string,
  anbestorMetaData: AncestorMetaData
): BreadcrumbItem[] => {
  const pathSplit = (p = '') => p.split('/').filter(Boolean)
  const current = pathSplit(currentRoute.path)
  const resource = pathSplit(resourcePath)

  return resource.map(
    (text, i) =>
      ({
        id: uuidv4(),
        allowContextActions: true,
        text,
        ...(i >= resource.length - Object.keys(anbestorMetaData).length && {
          to: {
            path: '/' + [...current].splice(0, current.length - resource.length + i + 1).join('/'),
            query: omit(currentRoute.query, 'fileId', 'page') // TODO: we need the correct fileId in the query. until we have that we must omit it because otherwise we would correct the path to the one of the (wrong) fileId.
          }
        }),
        isStaticNav: false
      } as BreadcrumbItem)
  )
}

export const concatBreadcrumbs = (...items: BreadcrumbItem[]): BreadcrumbItem[] => {
  const last = items.pop()

  return [
    ...items,
    {
      id: uuidv4(),
      allowContextActions: last.allowContextActions,
      text: last.text,
      onClick: () => eventBus.publish('app.files.list.load'),
      isTruncationPlaceholder: last.isTruncationPlaceholder,
      isStaticNav: last.isStaticNav
    }
  ]
}
