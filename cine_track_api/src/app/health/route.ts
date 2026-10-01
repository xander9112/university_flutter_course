import { getPayloadClient } from '@/lib/tmdb'

export const dynamic = 'force-dynamic'

/** Проверка для healthcheck Docker: сервер отвечает и база доступна. */
export async function GET(): Promise<Response> {
  try {
    const payload = await getPayloadClient()
    await payload.count({ collection: 'movies', overrideAccess: true })
    return new Response('ok', { headers: { 'Content-Type': 'text/plain' } })
  } catch {
    return new Response('database unavailable', { status: 503 })
  }
}
