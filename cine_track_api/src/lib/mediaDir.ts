import path from 'path'

/** Папка с загруженными изображениями: в Docker — volume из MEDIA_DIR, в dev — ./media. */
export const mediaDir = (): string => process.env.MEDIA_DIR || path.resolve(process.cwd(), 'media')
