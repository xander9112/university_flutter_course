/** Проверка и нормализация полей фильма — общая для импорта из TMDB и из ZIP-архива. */

export const isReleaseDate = (value: unknown): value is string =>
  typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)

/** Рейтинг 0–10 с одним знаком после точки или null. */
export function normalizeRating(value: unknown): number | null {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null
  return Math.min(10, Math.max(0, Math.round(value * 10) / 10))
}
