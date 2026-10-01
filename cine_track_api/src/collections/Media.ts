import type { CollectionConfig } from 'payload'

import { mediaDir } from '../lib/mediaDir'

/**
 * Постеры и фоновые кадры. Файлы лежат на диске в MEDIA_DIR (в Docker — volume),
 * приложение получает их по TMDB-совместимому пути /t/p/<размер>/<имя файла>.
 */
export const Media: CollectionConfig = {
  slug: 'media',
  labels: { singular: 'Изображение', plural: 'Изображения' },
  admin: {
    group: 'Контент',
  },
  access: {
    read: () => true,
    create: ({ req }) => Boolean(req.user),
    update: ({ req }) => Boolean(req.user),
    delete: ({ req }) => Boolean(req.user),
  },
  fields: [
    {
      name: 'alt',
      label: 'Описание',
      type: 'text',
      required: true,
    },
  ],
  upload: {
    staticDir: mediaDir(),
    mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
    // Приложение запрашивает постеры шириной 500 px (как w500 у TMDB). Высота — по пропорциям.
    imageSizes: [{ name: 'w500', width: 500, withoutEnlargement: true }],
    adminThumbnail: 'w500',
  },
}
