'use client'

import { Button } from '@payloadcms/ui'
import { useRouter } from 'next/navigation'
import { useState } from 'react'

type Result = { created: number; updated: number; errors: string[] } | { error: string }

/** Кнопка над списком фильмов: импорт популярных фильмов из TMDB (src/endpoints/importFromTmdb.ts). */
export function ImportFromTmdb() {
  const router = useRouter()
  const [pages, setPages] = useState(1)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  async function run() {
    setBusy(true)
    setMessage(null)
    try {
      const response = await fetch('/api/movies/import-tmdb', {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pages }),
      })
      const result = (await response.json()) as Result
      if ('error' in result) {
        setMessage(`Ошибка: ${result.error}`)
      } else {
        const errors = result.errors.length ? ` Ошибки: ${result.errors.join('; ')}` : ''
        setMessage(`Добавлено: ${result.created}, обновлено: ${result.updated}.${errors}`)
        router.refresh()
      }
    } catch {
      setMessage('Ошибка: сервер не ответил')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div
      style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap', marginBottom: 16 }}
    >
      <label>
        Страниц TMDB (по 20 фильмов):{' '}
        <input
          type="number"
          min={1}
          max={10}
          value={pages}
          onChange={(event) => setPages(Number(event.target.value))}
          style={{ width: 64 }}
        />
      </label>
      <Button buttonStyle="secondary" disabled={busy} onClick={run} margin={false}>
        {busy ? 'Импорт…' : 'Импортировать популярные из TMDB'}
      </Button>
      {message && <span>{message}</span>}
    </div>
  )
}
