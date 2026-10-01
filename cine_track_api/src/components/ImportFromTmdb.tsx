'use client'

import { Button } from '@payloadcms/ui'
import { useRouter } from 'next/navigation'
import { useCallback, useEffect, useRef, useState } from 'react'

import type { ImportJob } from '../endpoints/importFromTmdb'

const MODE_LABEL = { top: '100 лучших за 40 лет', popular: 'Популярные' } as const

/**
 * Над списком фильмов: импорт из TMDB (src/endpoints/importFromTmdb.ts). Импорт идёт на
 * сервере в фоне, кнопка опрашивает прогресс раз в 2 секунды — страницу можно закрыть
 * и открыть снова, прогресс подхватится.
 */
export function ImportFromTmdb() {
  const router = useRouter()
  const [pages, setPages] = useState(1)
  const [job, setJob] = useState<ImportJob | null>(null)
  const [error, setError] = useState<string | null>(null)
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null)

  const poll = useCallback(async () => {
    try {
      const response = await fetch('/api/movies/import-tmdb', { credentials: 'include' })
      const { job: state } = (await response.json()) as { job: ImportJob | null }
      setJob(state)
      if (state?.running) {
        timer.current = setTimeout(poll, 2000)
      } else if (state?.finishedAt) {
        router.refresh() // список фильмов под кнопкой
      }
    } catch {
      timer.current = setTimeout(poll, 5000)
    }
  }, [router])

  useEffect(() => {
    void poll()
    return () => {
      if (timer.current) clearTimeout(timer.current)
    }
  }, [poll])

  async function start(mode: keyof typeof MODE_LABEL) {
    setError(null)
    try {
      const response = await fetch('/api/movies/import-tmdb', {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ mode, pages }),
      })
      const result = (await response.json().catch(() => ({}))) as {
        job?: ImportJob
        error?: string
      }
      if (result.job) setJob(result.job)
      if (!response.ok && result.error) setError(result.error)
      if (timer.current) clearTimeout(timer.current)
      timer.current = setTimeout(poll, 1000)
    } catch {
      setError('сервер не ответил')
    }
  }

  const running = Boolean(job?.running)

  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap' }}>
        <Button
          buttonStyle="secondary"
          disabled={running}
          onClick={() => start('top')}
          margin={false}
        >
          Загрузить 100 лучших фильмов за 40 лет из TMDB
        </Button>
        <span style={{ opacity: 0.7 }}>или популярные сейчас:</span>
        <label>
          страниц по 20 фильмов{' '}
          <input
            type="number"
            min={1}
            max={10}
            value={pages}
            disabled={running}
            onChange={(event) => setPages(Number(event.target.value))}
            style={{ width: 56 }}
          />
        </label>
        <Button
          buttonStyle="secondary"
          disabled={running}
          onClick={() => start('popular')}
          margin={false}
        >
          Загрузить популярные
        </Button>
      </div>

      {error && <div style={{ marginTop: 8 }}>Ошибка: {error}</div>}

      {job && (
        <div style={{ marginTop: 8 }}>
          {MODE_LABEL[job.mode]}: {job.stage}
          {job.total > 0 && ` — ${job.processed} из ${job.total}`}
          {(job.created > 0 || job.updated > 0 || !job.running) &&
            `. Добавлено ${job.created}, обновлено ${job.updated}`}
          {job.running && '…'}
          {job.errors.length > 0 && (
            <ul style={{ margin: '4px 0 0', color: 'var(--theme-warning-500)' }}>
              {job.errors.map((message) => (
                <li key={message}>{message}</li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  )
}
