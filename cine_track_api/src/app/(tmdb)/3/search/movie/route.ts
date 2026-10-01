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

/** GET /3/search/movie?api_key=…&language=ru-RU&query=… — API.md, раздел 3. */
export async function GET(request: Request): Promise<Response> {
  // URL/URLSearchParams декодируют и %20, и + как пробел: Задание 11 шлёт %20, Dio — +
  const url = new URL(request.url)
  const payload = await getPayloadClient()

  const denied = await checkApiKey(payload, url)
  if (denied) return denied

  const page = parsePage(url)
  if (page instanceof Response) return page

  const query = (url.searchParams.get('query') ?? '').trim()
  // Пустой запрос — как у TMDB: 200 и пустой список, а не ошибка
  if (!query) return json(movieListResponse(page, [], 0))

  const result = await payload.find({
    collection: 'movies',
    where: {
      and: [
        { published: { equals: true } },
        // like — без учёта регистра, каждое слово запроса должно встретиться в названии
        { or: [{ title: { like: query } }, { originalTitle: { like: query } }] },
      ],
    },
    sort: ['-popularity', 'id'],
    page,
    limit: PAGE_SIZE,
    depth: 1,
    overrideAccess: true,
  })

  const docs = page > result.totalPages ? [] : result.docs
  return json(movieListResponse(page, docs, result.totalDocs))
}

export const OPTIONS = preflight
