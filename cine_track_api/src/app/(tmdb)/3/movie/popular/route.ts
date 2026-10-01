import {
  checkApiKey,
  getPayloadClient,
  json,
  movieListResponse,
  PAGE_SIZE,
  parsePage,
  preflight,
} from '@/lib/tmdb'

export const dynamic = 'force-dynamic'

/** GET /3/movie/popular?api_key=…&language=ru-RU&page=1 — API.md, раздел 2. */
export async function GET(request: Request): Promise<Response> {
  const url = new URL(request.url)
  const payload = await getPayloadClient()

  const denied = await checkApiKey(payload, url)
  if (denied) return denied

  const page = parsePage(url)
  if (page instanceof Response) return page

  const result = await payload.find({
    collection: 'movies',
    where: { published: { equals: true } },
    // id — второй ключ сортировки: при равной популярности порядок не «прыгает»
    // между pull-to-refresh
    sort: ['-popularity', 'id'],
    page,
    limit: PAGE_SIZE,
    depth: 1,
    overrideAccess: true,
  })

  // Страница за пределами диапазона — пустой results, но page из запроса
  const docs = page > result.totalPages ? [] : result.docs
  return json(movieListResponse(page, docs, result.totalDocs))
}

export const OPTIONS = preflight
