import { addDataAndFileToRequest, type Payload, type PayloadHandler } from 'payload'

import { genreValueOf, type GenreValue } from '../lib/genres'
import { isReleaseDate, normalizeRating } from '../lib/movieData'

/**
 * Импорт фильмов с постерами из настоящего TMDB — для преподавателя, у которого есть доступ
 * к TMDB; студентам он не нужен, они ходят в этот сервер.
 *
 *   POST /api/movies/import-tmdb { mode: 'top' }                 — 100 лучших за 40 лет
 *   POST /api/movies/import-tmdb { mode: 'popular', pages: 1..10 } — популярные сейчас
 *   GET  /api/movies/import-tmdb                                 — прогресс и отчёт
 *
 * Импорт идёт в фоне: 100 фильмов — это около 200 картинок и минута-две, а прокси (Nginx
 * Proxy Manager, nginx веб-версии) обрывают запросы дольше 60–120 секунд. POST сразу отвечает
 * 202, кнопка в админке опрашивает GET. Одновременно идёт только один импорт.
 *
 * Доступ к TMDB — переменные окружения сервера (не в коде и не в браузере):
 *   TMDB_IMPORT_ACCESS_TOKEN — API Read Access Token (заголовок Authorization: Bearer)
 *   TMDB_IMPORT_API_KEY      — или API Key v3 (параметр api_key)
 *
 * Повторный импорт обновляет фильмы по tmdbId и не скачивает уже загруженные картинки.
 * Флажок «Опубликован» у существующих фильмов не меняется.
 */

type TmdbMovie = {
  id: number
  title?: string
  original_title?: string
  overview?: string
  poster_path?: string | null
  backdrop_path?: string | null
  vote_average?: number
  release_date?: string
  genre_ids?: number[]
  popularity?: number
}

type Mode = 'top' | 'popular'

export type ImportJob = {
  mode: Mode
  running: boolean
  stage: string
  total: number
  processed: number
  created: number
  updated: number
  errors: string[]
  startedAt: string
  finishedAt: string | null
}

// Адреса можно переопределить (зеркало TMDB или проверка на мок-сервере)
const TMDB_API = process.env.TMDB_IMPORT_API_URL || 'https://api.themoviedb.org/3'
const TMDB_IMAGES = process.env.TMDB_IMPORT_IMAGES_URL || 'https://image.tmdb.org/t/p'

const TOP_COUNT = 100
const TOP_YEARS = 40
// Без порога по числу голосов вверху сортировки по рейтингу оказываются фильмы
// с двумя-тремя оценками по 10 — «лучшими» их не назовёшь
const TOP_MIN_VOTES = 1000
const MAX_PAGES = 10
const PARALLEL = 4

// Состояние последнего импорта — в памяти процесса: сервер один, история не нужна
let job: ImportJob | null = null

class TmdbError extends Error {}

function tmdbAuth(): { headers: Record<string, string>; query: string } | null {
  const token = process.env.TMDB_IMPORT_ACCESS_TOKEN?.trim()
  if (token) return { headers: { Authorization: `Bearer ${token}` }, query: '' }
  const key = process.env.TMDB_IMPORT_API_KEY?.trim()
  if (key) return { headers: {}, query: `api_key=${encodeURIComponent(key)}&` }
  return null
}

async function tmdbPage(
  auth: NonNullable<ReturnType<typeof tmdbAuth>>,
  path: string,
  params: Record<string, string | number>,
): Promise<TmdbMovie[]> {
  const query = Object.entries(params)
    .map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`)
    .join('&')
  let response: Response
  try {
    response = await fetch(`${TMDB_API}${path}?${auth.query}${query}`, {
      headers: { Accept: 'application/json', ...auth.headers },
      signal: AbortSignal.timeout(20_000),
    })
  } catch {
    // Текст ошибки fetch содержит URL — с api_key, если он задан. Наружу — без него
    throw new TmdbError('нет соединения с TMDB')
  }
  if (response.status === 401) throw new TmdbError('TMDB отклонил токен или ключ (401)')
  if (!response.ok) throw new TmdbError(`TMDB ответил ${response.status}`)
  return ((await response.json()) as { results?: TmdbMovie[] }).results ?? []
}

const isoDate = (date: Date) => date.toISOString().slice(0, 10)

/** Список фильмов для импорта: уникальные по id, в порядке TMDB. */
async function collectMovies(
  auth: NonNullable<ReturnType<typeof tmdbAuth>>,
  mode: Mode,
  pages: number,
): Promise<TmdbMovie[]> {
  const byId = new Map<number, TmdbMovie>()
  const limit = mode === 'top' ? TOP_COUNT : pages * 20
  const from = new Date()
  from.setFullYear(from.getFullYear() - TOP_YEARS)

  for (let page = 1; page <= MAX_PAGES && byId.size < limit; page++) {
    if (job) job.stage = `Список фильмов: страница ${page}`
    const results =
      mode === 'top'
        ? await tmdbPage(auth, '/discover/movie', {
            language: 'ru-RU',
            sort_by: 'vote_average.desc',
            'vote_count.gte': TOP_MIN_VOTES,
            'primary_release_date.gte': isoDate(from),
            'primary_release_date.lte': isoDate(new Date()),
            include_adult: 'false',
            include_video: 'false',
            page,
          })
        : await tmdbPage(auth, '/movie/popular', { language: 'ru-RU', page })
    if (results.length === 0) break
    for (const movie of results) {
      if (byId.size < limit && !byId.has(movie.id)) byId.set(movie.id, movie)
    }
    if (mode === 'popular' && page >= pages) break
  }
  return [...byId.values()]
}

/** Картинку храним под предсказуемым именем — повторный импорт находит её и не качает снова. */
async function ensureImage(
  payload: Payload,
  tmdbPath: string | null | undefined,
  size: 'w500' | 'w780',
  filename: string,
  alt: string,
): Promise<number | null> {
  if (!tmdbPath) return null
  const existing = await payload.find({
    collection: 'media',
    where: { filename: { equals: filename } },
    limit: 1,
    depth: 0,
  })
  if (existing.docs[0]) return existing.docs[0].id

  const response = await fetch(`${TMDB_IMAGES}/${size}${tmdbPath}`, {
    signal: AbortSignal.timeout(30_000),
  })
  if (!response.ok) throw new Error(`картинка не скачалась (${response.status})`)
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
  })
  return media.id
}

async function saveMovie(payload: Payload, item: TmdbMovie, state: ImportJob): Promise<void> {
  const title = item.title || item.original_title || `Фильм ${item.id}`
  const images: { poster?: number | null; backdrop?: number | null } = {}
  // Картинка не скачалась — фильм всё равно сохраняется, причина — в отчёт.
  // Поле при этом не трогаем: у существующего фильма останется прежняя картинка
  for (const [field, path, size, alt] of [
    ['poster', item.poster_path, 'w500', 'постер'],
    ['backdrop', item.backdrop_path, 'w780', 'кадр'],
  ] as const) {
    try {
      images[field] = await ensureImage(
        payload,
        path,
        size,
        `tmdb-${item.id}-${field}.jpg`,
        `${title} — ${alt}`,
      )
    } catch (error) {
      state.errors.push(`«${title}», ${alt}: ${error instanceof Error ? error.message : error}`)
    }
  }

  const data = {
    title,
    originalTitle: item.original_title || null,
    overview: item.overview?.trim() || null,
    ...images,
    voteAverage: normalizeRating(item.vote_average),
    releaseDate: isReleaseDate(item.release_date) ? item.release_date : null,
    genres: (item.genre_ids ?? [])
      .map(genreValueOf)
      .filter((value): value is GenreValue => value !== undefined),
    popularity: item.popularity ?? 0,
    tmdbId: item.id,
  }

  const existing = await payload.find({
    collection: 'movies',
    where: { tmdbId: { equals: item.id } },
    limit: 1,
    depth: 0,
  })
  if (existing.docs[0]) {
    await payload.update({ collection: 'movies', id: existing.docs[0].id, data })
    state.updated++
  } else {
    await payload.create({ collection: 'movies', data: { ...data, published: true } })
    state.created++
  }
}

async function runImport(
  payload: Payload,
  auth: NonNullable<ReturnType<typeof tmdbAuth>>,
  state: ImportJob,
  pages: number,
): Promise<void> {
  try {
    const movies = await collectMovies(auth, state.mode, pages)
    state.total = movies.length
    state.stage = 'Загрузка фильмов и постеров'

    // Несколько фильмов параллельно: картинки качаются заметно быстрее, а TMDB не
    // упирается в свой лимит запросов
    let next = 0
    const worker = async () => {
      while (next < movies.length) {
        const item = movies[next++]
        try {
          await saveMovie(payload, item, state)
        } catch (error) {
          state.errors.push(
            `«${item.title ?? item.id}»: ${error instanceof Error ? error.message : error}`,
          )
        } finally {
          state.processed++
        }
      }
    }
    await Promise.all(Array.from({ length: PARALLEL }, worker))
    state.stage = 'Готово'
  } catch (error) {
    state.errors.push(error instanceof TmdbError ? error.message : `ошибка импорта: ${error}`)
    state.stage = 'Остановлен из-за ошибки'
  } finally {
    state.running = false
    state.finishedAt = new Date().toISOString()
  }
}

/** POST — запустить импорт в фоне. */
export const startTmdbImport: PayloadHandler = async (req) => {
  if (!req.user) return Response.json({ error: 'Нужно войти в админку' }, { status: 401 })
  if (job?.running) return Response.json({ error: 'Импорт уже идёт', job }, { status: 409 })

  const auth = tmdbAuth()
  if (!auth) {
    return Response.json(
      {
        error:
          'Не задан доступ к TMDB: TMDB_IMPORT_ACCESS_TOKEN (API Read Access Token) или TMDB_IMPORT_API_KEY в переменных окружения сервера',
      },
      { status: 400 },
    )
  }

  await addDataAndFileToRequest(req)
  const body = (req.data ?? {}) as { mode?: unknown; pages?: unknown }
  const mode: Mode = body.mode === 'popular' ? 'popular' : 'top'
  const requested = Number(body.pages ?? 1)
  const pages = Number.isInteger(requested) ? Math.min(Math.max(requested, 1), MAX_PAGES) : 1

  job = {
    mode,
    running: true,
    stage: 'Запуск',
    total: 0,
    processed: 0,
    created: 0,
    updated: 0,
    errors: [],
    startedAt: new Date().toISOString(),
    finishedAt: null,
  }
  // Без await: запрос завершается сразу, импорт продолжается в процессе сервера
  void runImport(req.payload, auth, job, pages)
  return Response.json({ job }, { status: 202 })
}

/** GET — состояние последнего импорта. */
export const tmdbImportStatus: PayloadHandler = async (req) => {
  if (!req.user) return Response.json({ error: 'Нужно войти в админку' }, { status: 401 })
  return Response.json({ job })
}
