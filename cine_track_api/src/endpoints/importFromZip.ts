import crypto from 'crypto'
import path from 'path'

import { unzipSync } from 'fflate'
import {
  addDataAndFileToRequest,
  type PayloadHandler,
  type PayloadRequest,
  type Where,
} from 'payload'

import { GENRES, genreValueOf, type GenreValue } from '../lib/genres'
import { isReleaseDate, normalizeRating } from '../lib/movieData'

/**
 * POST /api/movies/import-zip (multipart, поле file) — импорт фильмов из ZIP-архива:
 * movies.json + картинки. Формат описан в README.md («Импорт из ZIP-архива»).
 *
 * - Фильм с `key` при повторной загрузке обновляется (поиск по importKey), без `key` —
 *   по `tmdb_id`, если он есть, иначе создаётся новый.
 * - Картинки сравниваются по содержимому (SHA-1 в имени файла): одна и та же картинка не
 *   сохраняется дважды, а изменённая загружается заново.
 * - Ошибка в одном фильме не отменяет остальные — она попадает в отчёт.
 */

type ZipMovie = {
  key?: unknown
  tmdb_id?: unknown
  title?: unknown
  original_title?: unknown
  overview?: unknown
  poster?: unknown
  backdrop?: unknown
  vote_average?: unknown
  release_date?: unknown
  genre_ids?: unknown
  genres?: unknown
  popularity?: unknown
  published?: unknown
}

type Report = { created: number; updated: number; errors: string[] }

const MIME_BY_EXT: Record<string, string> = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
}
const GENRE_VALUES = new Set<string>(GENRES.map((g) => g.value))

const fail = (status: number, error: string) => Response.json({ error }, { status })

/**
 * Находит movies.json — в корне архива или в единственной папке внутри (так получается,
 * если сжать папку целиком). Служебные папки macOS (__MACOSX, ._*) пропускаются.
 */
function findManifest(files: Record<string, Uint8Array>): string | undefined {
  return Object.keys(files)
    .filter((name) => !name.startsWith('__MACOSX/') && path.posix.basename(name) === 'movies.json')
    .sort((a, b) => a.split('/').length - b.split('/').length)[0]
}

/** Жанры: коды (`"action"`) в `genres` или id TMDB (`28`) в `genre_ids`. */
function parseGenres(movie: ZipMovie, problems: string[]): GenreValue[] {
  const result = new Set<GenreValue>()
  if (Array.isArray(movie.genres)) {
    for (const value of movie.genres) {
      if (typeof value === 'string' && GENRE_VALUES.has(value)) result.add(value as GenreValue)
      else problems.push(`неизвестный жанр ${JSON.stringify(value)}`)
    }
  }
  if (Array.isArray(movie.genre_ids)) {
    for (const id of movie.genre_ids) {
      const value = typeof id === 'number' ? genreValueOf(id) : undefined
      if (value) result.add(value)
      else problems.push(`неизвестный id жанра ${JSON.stringify(id)}`)
    }
  }
  return [...result]
}

async function saveImage(
  req: PayloadRequest,
  files: Record<string, Uint8Array>,
  baseDir: string,
  ref: unknown,
  alt: string,
): Promise<number | null> {
  if (ref === undefined || ref === null || ref === '') return null
  if (typeof ref !== 'string') throw new Error('путь к картинке должен быть строкой')

  // Путь — относительно папки с movies.json; «../» за пределы архива не пускаем
  const zipPath = path.posix.normalize(path.posix.join(baseDir, ref))
  if (zipPath.startsWith('../')) throw new Error(`путь «${ref}» выходит за пределы архива`)
  const data = files[zipPath]
  if (!data) throw new Error(`в архиве нет файла «${ref}»`)

  const ext = path.posix.extname(zipPath).toLowerCase()
  const mimetype = MIME_BY_EXT[ext]
  if (!mimetype) throw new Error(`«${ref}»: поддерживаются только JPG, PNG и WebP`)

  const hash = crypto.createHash('sha1').update(data).digest('hex').slice(0, 12)
  const stem = path.posix
    .basename(zipPath, ext)
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
  const filename = `zip-${hash}${stem ? `-${stem}` : ''}${ext === '.jpeg' ? '.jpg' : ext}`

  const existing = await req.payload.find({
    collection: 'media',
    where: { filename: { equals: filename } },
    limit: 1,
    depth: 0,
    req,
  })
  if (existing.docs[0]) return existing.docs[0].id

  const buffer = Buffer.from(data)
  const media = await req.payload.create({
    collection: 'media',
    data: { alt },
    file: { data: buffer, mimetype, name: filename, size: buffer.length },
    req,
  })
  return media.id
}

async function importMovie(
  req: PayloadRequest,
  files: Record<string, Uint8Array>,
  baseDir: string,
  movie: ZipMovie,
  report: Report,
): Promise<string[]> {
  const problems: string[] = []
  if (typeof movie.title !== 'string' || !movie.title.trim()) {
    throw new Error('нет названия (title)')
  }
  const title = movie.title.trim()
  const key = typeof movie.key === 'string' && movie.key.trim() ? movie.key.trim() : null
  const tmdbId =
    typeof movie.tmdb_id === 'number' && Number.isInteger(movie.tmdb_id) ? movie.tmdb_id : null

  if (
    movie.release_date !== undefined &&
    movie.release_date !== null &&
    movie.release_date !== '' &&
    !isReleaseDate(movie.release_date)
  ) {
    problems.push(`дата «${movie.release_date}» не в формате ГГГГ-ММ-ДД — не сохранена`)
  }

  if (
    typeof movie.vote_average === 'number' &&
    (movie.vote_average < 0 || movie.vote_average > 10)
  ) {
    problems.push(
      `рейтинг ${movie.vote_average} вне диапазона 0–10 — сохранён как ${normalizeRating(movie.vote_average)}`,
    )
  }

  // Картинка: нет поля в JSON — при обновлении не трогаем; не удалось прочитать — фильм
  // всё равно сохраняется (без этой картинки), а причина попадает в отчёт
  const images: { poster?: number | null; backdrop?: number | null } = {}
  for (const [field, alt] of [
    ['poster', 'постер'],
    ['backdrop', 'кадр'],
  ] as const) {
    if (!(field in movie)) continue
    try {
      images[field] = await saveImage(req, files, baseDir, movie[field], `${title} — ${alt}`)
    } catch (error) {
      problems.push(`${alt}: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  const data = {
    title,
    originalTitle:
      typeof movie.original_title === 'string' ? movie.original_title.trim() || null : null,
    overview: typeof movie.overview === 'string' ? movie.overview.trim() || null : null,
    ...images,
    voteAverage: normalizeRating(movie.vote_average),
    releaseDate: isReleaseDate(movie.release_date) ? movie.release_date : null,
    genres: parseGenres(movie, problems),
    popularity:
      typeof movie.popularity === 'number' && Number.isFinite(movie.popularity)
        ? movie.popularity
        : 0,
    ...(key ? { importKey: key } : {}),
    ...(tmdbId ? { tmdbId } : {}),
    ...(typeof movie.published === 'boolean' ? { published: movie.published } : {}),
  }

  const where: Where | null = key
    ? { importKey: { equals: key } }
    : tmdbId
      ? { tmdbId: { equals: tmdbId } }
      : null
  const existing = where
    ? (await req.payload.find({ collection: 'movies', where, limit: 1, depth: 0, req })).docs[0]
    : undefined

  if (existing) {
    await req.payload.update({ collection: 'movies', id: existing.id, data, req })
    report.updated++
  } else {
    await req.payload.create({ collection: 'movies', data: { published: true, ...data }, req })
    report.created++
  }
  return problems
}

export const importFromZip: PayloadHandler = async (req) => {
  if (!req.user) return fail(401, 'Нужно войти в админку')

  await addDataAndFileToRequest(req)
  const file = req.file
  if (!file) return fail(400, 'Не выбран файл: отправьте ZIP-архив в поле file')
  if ((file as { truncated?: boolean }).truncated) {
    return fail(413, 'Архив больше допустимого размера (200 МБ)')
  }

  let files: Record<string, Uint8Array>
  try {
    files = unzipSync(new Uint8Array(file.data))
  } catch {
    return fail(400, 'Файл не похож на ZIP-архив')
  }

  const manifest = findManifest(files)
  if (!manifest) return fail(400, 'В архиве нет movies.json')

  let parsed: unknown
  try {
    parsed = JSON.parse(new TextDecoder('utf-8').decode(files[manifest]).replace(/^﻿/, ''))
  } catch (error) {
    return fail(
      400,
      `movies.json — некорректный JSON: ${error instanceof Error ? error.message : error}`,
    )
  }
  // Корень — массив фильмов или объект с полем movies (или results, как в ответе TMDB)
  const list = Array.isArray(parsed)
    ? parsed
    : ((parsed as { movies?: unknown; results?: unknown })?.movies ??
      (parsed as { results?: unknown })?.results)
  if (!Array.isArray(list)) {
    return fail(400, 'movies.json: ожидается массив фильмов или объект { "movies": [...] }')
  }

  const baseDir = path.posix.dirname(manifest) === '.' ? '' : path.posix.dirname(manifest)
  const report: Report = { created: 0, updated: 0, errors: [] }
  for (const [index, item] of list.entries()) {
    const label =
      item && typeof item === 'object' && typeof (item as ZipMovie).title === 'string'
        ? `«${(item as ZipMovie).title}»`
        : `Фильм №${index + 1}`
    try {
      if (!item || typeof item !== 'object') throw new Error('ожидается объект')
      const problems = await importMovie(req, files, baseDir, item as ZipMovie, report)
      for (const problem of problems) report.errors.push(`${label}: ${problem}`)
    } catch (error) {
      report.errors.push(
        `${label}: ${error instanceof Error ? error.message : String(error)} — пропущен`,
      )
    }
  }
  return Response.json(report)
}
