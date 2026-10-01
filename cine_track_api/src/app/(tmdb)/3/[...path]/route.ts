import { notFound, preflight } from '@/lib/tmdb'

/** Остальные пути /3/... — 404 в формате TMDB (с CORS, чтобы веб-версия видела код). */
export const GET = notFound
export const OPTIONS = preflight
