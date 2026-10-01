import crypto from 'crypto'
import type { CollectionConfig } from 'payload'

/**
 * Ключи для параметра api_key. Обычно достаточно одного общего ключа курса, который
 * студенты передают через --dart-define=TMDB_API_KEY=... (Задание 11). Отключённый
 * ключ (active = false) получает 401.
 */
export const ApiKeys: CollectionConfig = {
  slug: 'api-keys',
  labels: { singular: 'API-ключ', plural: 'API-ключи' },
  admin: {
    useAsTitle: 'label',
    defaultColumns: ['label', 'key', 'active', 'updatedAt'],
    group: 'Администрирование',
  },
  access: {
    // Ключи видит только администратор: проверка ключа на сервере идёт через Local API
    // с overrideAccess, а не через публичный REST.
    read: ({ req }) => Boolean(req.user),
    create: ({ req }) => Boolean(req.user),
    update: ({ req }) => Boolean(req.user),
    delete: ({ req }) => Boolean(req.user),
  },
  fields: [
    {
      name: 'label',
      label: 'Название',
      type: 'text',
      required: true,
      admin: { description: 'Например, «Группа ИВТ-21, осень 2026»' },
    },
    {
      name: 'key',
      label: 'Ключ',
      type: 'text',
      required: true,
      unique: true,
      index: true,
      defaultValue: () => crypto.randomBytes(16).toString('hex'),
      admin: { description: 'Сгенерирован автоматически, можно задать свой' },
    },
    {
      name: 'active',
      label: 'Активен',
      type: 'checkbox',
      defaultValue: true,
    },
  ],
}
