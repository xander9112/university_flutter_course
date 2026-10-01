import { addDataAndFileToRequest, type PayloadHandler, type PayloadRequest } from 'payload'

import { genreValueOf, type GenreValue } from '../lib/genres'

/**
 * POST /api/movies/import-tmdb { pages: 1..10 } — загружает популярные фильмы из настоящего
 * TMDB вместе с постерами. Нужен ключ TMDB преподавателя в TMDB_IMPORT_API_KEY; студентам
 * ключ TMDB не нужен — они ходят в этот сервер. Повторный импорт обновляет фильмы по tmdbId
 * и не скачивает уже загруженные картинки заново.
 */

type TmdbMovie = {
  id: number
  title: string
  original_title?: string
  overview?: string
  poster_path?: string | null
  backdrop_path?: string | null
  vote_average?: number
  release_date?: string
  genre_ids?: number[]
  popularity?: number
}

// Адреса можно переопределить (например, для зеркала TMDB или для проверки на мок-сервере)
const TMDB_API = process.env.TMDB_IMPORT_API_URL || 'https://api.themoviedb.org/3'
const TMDB_IMAGES = process.env.TMDB_IMPORT_IMAGES_URL || 'https://image.tmdb.org/t/p'
const MAX_PAGES = 10

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url, { signal: AbortSignal.timeout(20_000) })
  if (!response.ok) throw new Error(`TMDB ответил ${response.status}`)
  return (await response.json()) as T
}

/** Картинку храним под предсказуемым именем — так повторный импорт находит её и не качает снова. */
async function ensureImage(
  req: PayloadRequest,
  tmdbPath: string | null | undefined,
  size: 'w500' | 'w780',
  filename: string,
  alt: string,
): Promise<number | null> {
  if (!tmdbPath) return null
  const { payload } = req
  const existing = await payload.find({
    collection: 'media',
    where: { filename: { equals: filename } },
    limit: 1,
    depth: 0,
    req,
  })
  if (existing.docs[0]) return existing.docs[0].id

  const response = await fetch(`${TMDB_IMAGES}/${size}${tmdbPath}`, {
    signal: AbortSignal.timeout(20_000),
  })
  if (!response.ok) return null
  const data = Buffer.from(await response.arrayBuffer())
  const media = await payload.create({
    collection: 'media',
    data: { alt },
    file: {
      data,
      mimetype: response.headers.get('content-type') || 'image/jpeg',
      name: filename,
      size: data.length,
    },
    req,
  })
  return media.id
}

export const importFromTmdb: PayloadHandler = async (req) => {
  if (!req.user) {
    return Response.json({ error: 'Нужно войти в админку' }, { status: 401 })
  }
  const apiKey = process.env.TMDB_IMPORT_API_KEY
  if (!apiKey) {
    return Response.json(
      { error: 'Не задан TMDB_IMPORT_API_KEY в переменных окружения сервера' },
      { status: 400 },
    )
  }

  await addDataAndFileToRequest(req)
  const requested = Number((req.data as { pages?: unknown } | undefined)?.pages ?? 1)
  const pages = Number.isInteger(requested) ? Math.min(Math.max(requested, 1), MAX_PAGES) : 1

  let created = 0
  let updated = 0
  const errors: string[] = []

  for (let page = 1; page <= pages; page++) {
    let results: TmdbMovie[]
    try {
      const body = await fetchJson<{ results: TmdbMovie[] }>(
        `${TMDB_API}/movie/popular?api_key=${encodeURIComponent(apiKey)}&language=ru-RU&page=${page}`,
      )
      results = body.results
    } catch (error) {
      // Текст ошибки fetch может содержать URL с ключом — наружу отдаём без него
      errors.push(`Страница ${page}: ${error instanceof Error && error.message.startsWith('TMDB') ? error.message : 'нет соединения с TMDB'}`)
      break
    }

    for (const item of results) {
      try {
        const title = item.title || item.original_title || `Фильм ${item.id}`
        const poster = await ensureImage(req, item.poster_path, 'w500', `tmdb-${item.id}-poster.jpg`, `${title} — постер`)
        const backdrop = await ensureImage(req, item.backdrop_path, 'w780', `tmdb-${item.id}-backdrop.jpg`, `${title} — кадр`)
        const data = {
          title,
          originalTitle: item.original_title || null,
          overview: item.overview?.trim() || null,
          poster,
          backdrop,
          voteAverage: typeof item.vote_average === 'number' ? Math.round(item.vote_average * 10) / 10 : null,
          releaseDate: /^\d{4}-\d{2}-\d{2}$/.test(item.release_date ?? '') ? item.release_date : null,
          genres: (item.genre_ids ?? [])
            .map(genreValueOf)
            .filter((value): value is GenreValue => value !== undefined),
          popularity: item.popularity ?? 0,
          tmdbId: item.id,
        }

        const existing = await req.payload.find({
          collection: 'movies',
          where: { tmdbId: { equals: item.id } },
          limit: 1,
          depth: 0,
          req,
        })
        if (existing.docs[0]) {
          // published не трогаем: если фильм скрыли вручную, импорт его не вернёт
          await req.payload.update({ collection: 'movies', id: existing.docs[0].id, data, req })
          updated++
        } else {
          await req.payload.create({ collection: 'movies', data: { ...data, published: true }, req })
          created++
        }
      } catch (error) {
        errors.push(`«${item.title}»: ${error instanceof Error ? error.message : String(error)}`)
      }
    }
  }

  return Response.json({ created, updated, errors })
}
