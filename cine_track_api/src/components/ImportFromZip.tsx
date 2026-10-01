'use client'

import { Button } from '@payloadcms/ui'
import { useRouter } from 'next/navigation'
import { useRef, useState } from 'react'

type Report = { created: number; updated: number; errors: string[] }

/** Над списком фильмов: загрузка ZIP-архива с movies.json и картинками (src/endpoints/importFromZip.ts). */
export function ImportFromZip() {
  const router = useRouter()
  const input = useRef<HTMLInputElement>(null)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const [errors, setErrors] = useState<string[]>([])

  async function upload(file: File) {
    setBusy(true)
    setMessage(null)
    setErrors([])
    try {
      const form = new FormData()
      form.append('file', file)
      const response = await fetch('/api/movies/import-zip', {
        method: 'POST',
        credentials: 'include',
        body: form,
      })
      const result = (await response.json().catch(() => ({}))) as Partial<Report> & {
        error?: string
      }
      if (!response.ok || typeof result.created !== 'number') {
        // 413 — архив больше лимита: его отклоняет nginx или сам Payload ещё до импорта
        const reason =
          response.status === 413
            ? 'архив больше 200 МБ'
            : result.error || `сервер ответил ${response.status}`
        setMessage(`Ошибка: ${reason}`)
      } else {
        setMessage(
          `Архив «${file.name}»: добавлено ${result.created}, обновлено ${result.updated ?? 0}.`,
        )
        setErrors(result.errors ?? [])
        router.refresh()
      }
    } catch {
      setMessage('Ошибка: сервер не ответил')
    } finally {
      setBusy(false)
      if (input.current) input.current.value = ''
    }
  }

  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap' }}>
        <input
          ref={input}
          type="file"
          accept=".zip,application/zip"
          style={{ display: 'none' }}
          onChange={(event) => {
            const file = event.target.files?.[0]
            if (file) void upload(file)
          }}
        />
        <Button
          buttonStyle="secondary"
          disabled={busy}
          onClick={() => input.current?.click()}
          margin={false}
        >
          {busy ? 'Загрузка…' : 'Загрузить ZIP-архив с фильмами'}
        </Button>
        <span style={{ opacity: 0.7 }}>movies.json и картинки — формат в README.md</span>
        {message && <span>{message}</span>}
      </div>
      {errors.length > 0 && (
        <ul style={{ margin: '8px 0 0', color: 'var(--theme-warning-500)' }}>
          {errors.map((error) => (
            <li key={error}>{error}</li>
          ))}
        </ul>
      )}
    </div>
  )
}
