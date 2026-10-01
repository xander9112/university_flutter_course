import type { CollectionConfig } from 'payload'

/** Администраторы CMS. Первый пользователь создаётся на /admin при первом входе. */
export const Users: CollectionConfig = {
  slug: 'users',
  labels: { singular: 'Пользователь', plural: 'Пользователи' },
  admin: {
    useAsTitle: 'email',
    group: 'Администрирование',
  },
  auth: true,
  access: {
    // Регистрации нет: управлять учётками может только вошедший администратор.
    // Самого первого пользователя Payload разрешает создать без авторизации.
    read: ({ req }) => Boolean(req.user),
    create: ({ req }) => Boolean(req.user),
    update: ({ req }) => Boolean(req.user),
    delete: ({ req }) => Boolean(req.user),
  },
  fields: [],
}
