/**
 * Общие части TMDB-совместимого API (/3/...): заголовки, ошибки, проверка api_key и
 * сериализация фильма. Требования к формату — API.md в корне репозитория курса.
 */
import config from '@payload-config'
import { getPayload, type Payload } from 'payload'

import type { Media, Movie } from '../payload-types'
import { genreIdOf } from './genres'

/** CORS для Flutter Web: заголовки нужны во всех ответах, в том числе в ошибках. */
export const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': '*',
} as const

export const PAGE_SIZE = 20
const MAX_PAGE = 500

export const getPayloadClient = (): Promise<Payload> => getPayload({ config })

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...CORS_HEADERS,
      // charset обязателен: без него не все клиенты читают кириллицу как UTF-8
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    },
  })
}

/** Ошибка в формате TMDB: приложение смотрит только на HTTP-код, тело — для отладки. */
export const tmdbError = (status: number, statusCode: number, message: string): Response =>
  json({ success: false, status_code: statusCode, status_message: message }, status)

export const notFound = (): Response =>
  tmdbError(404, 34, 'The resource you requested could not be found.')

export const preflight = (): Response => new Response(null, { status: 204, headers: CORS_HEADERS })

// Ключи проверяются на каждый запрос — кэшируем результат на 30 секунд, чтобы не ходить
// в базу за каждым символом поиска. Отключённый в админке ключ перестаёт работать
// не позже чем через 30 секунд.
const KEY_TTL_MS = 30_000
const keyCache = new Map<string, { valid: boolean; expires: number }>()

async function isValidApiKey(payload: Payload, key: string): Promise<boolean> {
  const cached = keyCache.get(key)
  if (cached && cached.expires > Date.now()) return cached.valid
  const { totalDocs } = await payload.count({
    collection: 'api-keys',
    where: { key: { equals: key }, active: { equals: true } },
    overrideAccess: true,
  })
  const valid = totalDocs > 0
  keyCache.set(key, { valid, expires: Date.now() + KEY_TTL_MS })
  return valid
}

/** null — ключ верный; иначе готовый ответ 401. */
export async function checkApiKey(payload: Payload, url: URL): Promise<Response | null> {
  const key = url.searchParams.get('api_key')?.trim()
  if (key && (await isValidApiKey(payload, key))) return null
  return tmdbError(401, 7, 'Invalid API key: You must be granted a valid key.')
}

/** Номер страницы из ?page=: число от 1 до 500 (как у TMDB), без параметра — 1. */
export function parsePage(url: URL): number | Response {
  const raw = url.searchParams.get('page')
  if (raw === null || raw === '') return 1
  const page = Number(raw)
  if (!Number.isInteger(page) || page < 1 || page > MAX_PAGE) {
    return tmdbError(
      422,
      22,
      'Invalid page: Pages start at 1 and max at 500. They are expected to be an integer.',
    )
  }
  return page
}

/** Путь картинки для poster_path/backdrop_path: «/<файл>», или null, если её нет. */
function imagePath(media: Movie['poster']): string | null {
  if (!media || typeof media !== 'object') return null
  const { filename } = media as Media
  return filename ? `/${encodeURIComponent(filename)}` : null
}

/** Фильм в формате TMDB. Типы полей строгие — см. раздел 5 API.md. */
export function serializeMovie(movie: Movie) {
  const overview = movie.overview?.trim()
  return {
    id: movie.id,
    title: movie.title,
    original_title: movie.originalTitle || movie.title,
    // null, а не "": на null экран деталей пишет «Описание отсутствует»
    overview: overview ? overview : null,
    poster_path: imagePath(movie.poster),
    backdrop_path: imagePath(movie.backdrop),
    vote_average: typeof movie.voteAverage === 'number' ? movie.voteAverage : null,
    release_date: movie.releaseDate || '',
    genre_ids: (movie.genres ?? [])
      .map((value) => genreIdOf(value))
      .filter((id): id is number => id !== undefined),
    popularity: movie.popularity ?? 0,
    adult: false,
    video: false,
  }
}

/** Страница списка фильмов в формате TMDB. */
export function movieListResponse(
  page: number,
  docs: Movie[],
  totalDocs: number,
): Record<string, unknown> {
  return {
    page,
    results: docs.map(serializeMovie),
    total_pages: Math.max(1, Math.ceil(totalDocs / PAGE_SIZE)),
    total_results: totalDocs,
  }
}
