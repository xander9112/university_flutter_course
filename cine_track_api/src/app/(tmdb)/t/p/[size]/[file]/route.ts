import { readFile } from 'fs/promises'
import path from 'path'

import { mediaDir } from '@/lib/mediaDir'
import { CORS_HEADERS, getPayloadClient, preflight } from '@/lib/tmdb'
import type { Media } from '@/payload-types'

export const dynamic = 'force-dynamic'

// w500 — то, что запрашивает приложение (https://…/t/p/w500<poster_path>), original — исходник
const SIZES = new Set(['w500', 'original'])

const imageNotFound = (): Response =>
  new Response('Not found', { status: 404, headers: { ...CORS_HEADERS, 'Content-Type': 'text/plain' } })

/** GET /t/p/<размер>/<файл> — картинки в том же формате пути, что image.tmdb.org (API.md, раздел 7). */
export async function GET(
  _request: Request,
  { params }: { params: Promise<{ size: string; file: string }> },
): Promise<Response> {
  const { size, file } = await params
  let filename = file
  try {
    filename = decodeURIComponent(file)
  } catch {
    // уже декодировано — используем как есть
  }
  // Только имя файла, без подкаталогов: защита от «../» в пути
  if (!SIZES.has(size) || filename !== path.basename(filename)) return imageNotFound()

  const payload = await getPayloadClient()
  const { docs } = await payload.find({
    collection: 'media',
    where: { filename: { equals: filename } },
    limit: 1,
    depth: 0,
    overrideAccess: true,
  })
  const media = docs[0] as Media | undefined
  if (!media?.filename) return imageNotFound()

  // Уменьшенная копия есть, только если исходник шире 500 px (withoutEnlargement)
  const variant = size === 'w500' ? media.sizes?.w500 : undefined
  const servedName = variant?.filename || media.filename
  const mimeType = (variant?.filename && variant.mimeType) || media.mimeType || 'image/jpeg'

  try {
    const data = await readFile(path.join(mediaDir(), servedName))
    return new Response(new Uint8Array(data), {
      headers: {
        ...CORS_HEADERS, // Flutter Web загружает картинки через fetch — без CORS постеров не будет
        'Content-Type': mimeType,
        'Cache-Control': 'public, max-age=86400',
      },
    })
  } catch {
    return imageNotFound()
  }
}

export const OPTIONS = preflight
