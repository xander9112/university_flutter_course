import React from 'react'

export const metadata = {
  title: 'CineTrack API',
  description: 'TMDB-совместимый API для учебного приложения CineTrack',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ru">
      <body style={{ fontFamily: 'system-ui, sans-serif', maxWidth: 720, margin: '40px auto', padding: '0 16px', lineHeight: 1.5 }}>
        {children}
      </body>
    </html>
  )
}
