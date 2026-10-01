/**
 * Жанры TMDB. В базе жанр хранится строковым кодом (`action`), а в API отдаётся числовым
 * id TMDB (`28`) — по этим id приложение CineTrack показывает названия (lib/.../genres.dart).
 * Коды, а не числа, потому что значения select-поля становятся и enum в Postgres, и
 * идентификаторами в схеме, а они не могут начинаться с цифры.
 */
export const GENRES = [
  { value: 'action', id: 28, label: 'Боевик' },
  { value: 'adventure', id: 12, label: 'Приключения' },
  { value: 'animation', id: 16, label: 'Мультфильм' },
  { value: 'comedy', id: 35, label: 'Комедия' },
  { value: 'crime', id: 80, label: 'Криминал' },
  { value: 'documentary', id: 99, label: 'Документальный' },
  { value: 'drama', id: 18, label: 'Драма' },
  { value: 'family', id: 10751, label: 'Семейный' },
  { value: 'fantasy', id: 14, label: 'Фэнтези' },
  { value: 'history', id: 36, label: 'История' },
  { value: 'horror', id: 27, label: 'Ужасы' },
  { value: 'music', id: 10402, label: 'Музыка' },
  { value: 'mystery', id: 9648, label: 'Детектив' },
  { value: 'romance', id: 10749, label: 'Мелодрама' },
  { value: 'science_fiction', id: 878, label: 'Фантастика' },
  { value: 'tv_movie', id: 10770, label: 'Телевизионный фильм' },
  { value: 'thriller', id: 53, label: 'Триллер' },
  { value: 'war', id: 10752, label: 'Военный' },
  { value: 'western', id: 37, label: 'Вестерн' },
] as const

export type GenreValue = (typeof GENRES)[number]['value']

const idByValue = new Map<string, number>(GENRES.map((g) => [g.value, g.id]))
const valueById = new Map<number, GenreValue>(GENRES.map((g) => [g.id, g.value]))

export const genreIdOf = (value: string): number | undefined => idByValue.get(value)
export const genreValueOf = (id: number): GenreValue | undefined => valueById.get(id)
