import { Response } from 'node-fetch'
import join from 'join-path'
import { checkResponseStatus, request } from '../http'
import { Space, User } from '../../types'
import {
  createFolderInsideSpaceBySpaceName,
  getIdOfFileInsideSpace,
  uploadFileInsideSpaceBySpaceName
} from '../davSpaces'

export const getPersonalSpaceId = async ({ user }: { user: User }): Promise<string> => {
  const response = await request({
    method: 'GET',
    path: join('graph', 'v1.0', 'me', 'drives', "?$filter=driveType eq 'personal'"),
    user: user
  })

  checkResponseStatus(response, 'Failed while geting personal space')

  const result = await response.json()
  return result.value[0].id
}

export const getSpaceIdBySpaceName = async ({
  user,
  spaceType,
  spaceName
}: {
  user: User
  spaceType: string
  spaceName: string
}): Promise<string> => {
  const response = await request({
    method: 'GET',
    path: join('graph', 'v1.0', 'me', 'drives', `?$filter=driveType eq '${spaceType}'`),
    user: user
  })
  checkResponseStatus(response, 'Failed while fetching spaces')
  // search for the space with the space name
  const result = await response.json()
  for (const spaceProject of result.value) {
    if (spaceProject.name === spaceName) {
      return spaceProject.id
    }
  }
  throw new Error(`Could not find space ${spaceName}`)
}

export const createSpace = async ({
  user,
  space
}: {
  user: User
  space: Space
}): Promise<string> => {
  const body = JSON.stringify({
    id: space.id,
    name: space.name
  })

  const response = await request({
    method: 'POST',
    path: join('graph', 'v1.0', 'drives'),
    body,
    user: user
  })

  // To make api request work consistently with UI we need to create a hidden folder '.space'
  // Inside .space it consist of files that may be required to update the space (e.g. change description of space (stored by readme.md), change image of space)

  checkResponseStatus(response, 'Failed while creating a space project')

  const result = await response.json()
  const spaceName = result.name
  // API call to make a hidden file when the space creation is successful
  await createFolderInsideSpaceBySpaceName({ user, folder: '.space', spaceName })
  // Again make an api call to create a readme.md file so that the description is shown in the web UI
  await uploadFileInsideSpaceBySpaceName({ user, pathToFile: '.space/readme.md', spaceName })
  // Again make an api call to get file id of the uploaded file `readme.md`
  const fileId = await getIdOfFileInsideSpace({
    user,
    pathToFileName: '.space/readme.md',
    spaceType: 'project',
    spaceName
  })
  // After getting file id make a patch request to update space special section
  await updateSpaceSpecialSection({
    user,
    spaceId: result.id,
    type: 'description',
    fileId: fileId
  })

  return result.id
}

export const updateSpaceSpecialSection = async ({
  user,
  spaceId,
  type,
  fileId
}: {
  user: User
  spaceId: string
  type: string
  fileId: string
}): Promise<void> => {
  if (type === 'description') {
    type = 'readme'
  } else {
    type = 'image'
  }
  const body = JSON.stringify({
    special: [
      {
        specialFolder: {
          name: type
        },
        id: fileId
      }
    ]
  })

  const response = await request({
    method: 'PATCH',
    path: join('graph', 'v1.0', 'drives', spaceId),
    body: body,
    user: user
  })
  checkResponseStatus(
    response,
    `Failed while creating special section "${type}" inside project space`
  )
}

export const disableSpace = ({ user, space }: { user: User; space: Space }): Promise<Response> => {
  return request({
    method: 'DELETE',
    path: join('graph', 'v1.0', 'drives', space.id),
    user: user
  })
}

export const deleteSpace = ({ user, space }: { user: User; space: Space }): Promise<Response> => {
  return request({
    method: 'DELETE',
    path: join('graph', 'v1.0', 'drives', space.id),
    user: user,
    header: { Purge: 'T' }
  })
}
