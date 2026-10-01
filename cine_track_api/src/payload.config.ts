import { postgresAdapter } from '@payloadcms/db-postgres'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import { ru } from '@payloadcms/translations/languages/ru'
import path from 'path'
import { buildConfig } from 'payload'
import { fileURLToPath } from 'url'
import sharp from 'sharp'

import { ApiKeys } from './collections/ApiKeys'
import { Media } from './collections/Media'
import { Movies } from './collections/Movies'
import { Users } from './collections/Users'
import { migrations } from './migrations'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

export default buildConfig({
  admin: {
    user: Users.slug,
    importMap: {
      baseDir: path.resolve(dirname),
    },
    meta: {
      titleSuffix: ' — CineTrack API',
    },
  },
  // Админка на русском — ей пользуется преподаватель курса
  i18n: {
    supportedLanguages: { ru },
    fallbackLanguage: 'ru',
  },
  collections: [Movies, Media, ApiKeys, Users],
  editor: lexicalEditor(),
  secret: process.env.PAYLOAD_SECRET || '',
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  db: postgresAdapter({
    pool: {
      connectionString: process.env.DATABASE_URL || '',
    },
    // В dev схема синхронизируется автоматически (push), в production — нет: там применяются
    // только миграции из src/migrations (автоматически при старте). Без prodMigrations на
    // пустой базе каждый запрос падает с `relation "..." does not exist`.
    prodMigrations: migrations,
  }),
  sharp,
  // Лимит размера загружаемого файла: по умолчанию Payload принимает до 20 МБ, а ZIP-архиву
  // с постерами нужно больше. Тот же лимит — у nginx веб-версии (client_max_body_size).
  upload: {
    limits: { fileSize: 200 * 1024 * 1024 },
  },
  graphQL: {
    disable: true, // приложению GraphQL не нужен, только REST в формате TMDB
  },
})
