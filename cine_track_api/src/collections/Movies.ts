import type { CollectionConfig } from 'payload'

import { startTmdbImport, tmdbImportStatus } from '../endpoints/importFromTmdb'
import { importFromZip } from '../endpoints/importFromZip'
import { GENRES } from '../lib/genres'

/**
 * Фильмы — то, что отдают /3/movie/popular и /3/search/movie (формат — API.md в корне
 * репозитория курса). id документа — целое из Postgres (serial): приложение хранит по нему
 * избранное и личные оценки, поэтому id не должен меняться.
 */
export const Movies: CollectionConfig = {
  slug: 'movies',
  labels: { singular: 'Фильм', plural: 'Фильмы' },
  admin: {
    useAsTitle: 'title',
    listSearchableFields: ['title', 'originalTitle'],
    defaultColumns: ['title', 'releaseDate', 'voteAverage', 'popularity', 'published'],
    group: 'Контент',
    components: {
      beforeListTable: [
        './components/ImportFromZip#ImportFromZip',
        './components/ImportFromTmdb#ImportFromTmdb',
      ],
    },
  },
  defaultSort: '-popularity',
  access: {
    // Публичный REST Payload (/api/movies) отдаёт только опубликованные фильмы;
    // приложение ходит не сюда, а в /3/... (src/app/(tmdb)).
    read: ({ req }) => (req.user ? true : { published: { equals: true } }),
    create: ({ req }) => Boolean(req.user),
    update: ({ req }) => Boolean(req.user),
    delete: ({ req }) => Boolean(req.user),
  },
  endpoints: [
    {
      path: '/import-tmdb',
      method: 'post',
      handler: startTmdbImport,
    },
    {
      path: '/import-tmdb',
      method: 'get',
      handler: tmdbImportStatus,
    },
    {
      path: '/import-zip',
      method: 'post',
      handler: importFromZip,
    },
  ],
  fields: [
    {
      name: 'title',
      label: 'Название',
      type: 'text',
      required: true,
      index: true,
    },
    {
      name: 'originalTitle',
      label: 'Оригинальное название',
      type: 'text',
      index: true,
      admin: { description: 'По нему тоже работает поиск: «Matrix» найдёт «Матрицу»' },
    },
    {
      name: 'overview',
      label: 'Описание',
      type: 'textarea',
    },
    {
      type: 'row',
      fields: [
        {
          name: 'poster',
          label: 'Постер',
          type: 'upload',
          relationTo: 'media',
          admin: { description: 'Вертикальный, 2:3' },
        },
        {
          name: 'backdrop',
          label: 'Фоновый кадр',
          type: 'upload',
          relationTo: 'media',
        },
      ],
    },
    {
      type: 'row',
      fields: [
        {
          name: 'releaseDate',
          label: 'Дата выхода',
          type: 'text',
          // Строка, а не date-поле: API отдаёт ровно «ГГГГ-ММ-ДД», без часового пояса,
          // а date-поле хранит момент времени и при сериализации может сдвинуть день.
          admin: { placeholder: 'ГГГГ-ММ-ДД', width: '33%' },
          validate: (value: string | null | undefined) =>
            !value || /^\d{4}-\d{2}-\d{2}$/.test(value) || 'Формат даты — ГГГГ-ММ-ДД',
        },
        {
          name: 'voteAverage',
          label: 'Рейтинг',
          type: 'number',
          min: 0,
          max: 10,
          admin: { step: 0.1, width: '33%' },
        },
        {
          name: 'popularity',
          label: 'Популярность',
          type: 'number',
          defaultValue: 0,
          index: true,
          admin: {
            width: '33%',
            description: 'Порядок в /3/movie/popular: чем больше, тем выше',
          },
        },
      ],
    },
    {
      name: 'genres',
      label: 'Жанры',
      type: 'select',
      hasMany: true,
      options: GENRES.map(({ value, label }) => ({ value, label })),
    },
    {
      name: 'published',
      label: 'Опубликован',
      type: 'checkbox',
      defaultValue: true,
      index: true,
      admin: {
        position: 'sidebar',
        description: 'Неопубликованные фильмы не попадают в API',
      },
    },
    {
      name: 'importKey',
      label: 'Ключ импорта',
      type: 'text',
      unique: true,
      index: true,
      admin: {
        position: 'sidebar',
        readOnly: true,
        description: 'Поле key из movies.json: по нему повторная загрузка архива обновляет фильм',
      },
    },
    {
      name: 'tmdbId',
      label: 'ID в TMDB',
      type: 'number',
      unique: true,
      index: true,
      admin: {
        position: 'sidebar',
        readOnly: true,
        description: 'Заполняется импортом из TMDB; по нему повторный импорт обновляет фильм',
      },
    },
  ],
}
