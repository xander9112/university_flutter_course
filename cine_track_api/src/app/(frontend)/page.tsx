export default function HomePage() {
  return (
    <main>
      <h1>CineTrack API</h1>
      <p>
        TMDB-совместимый API для учебного приложения CineTrack. Требования к формату — файл API.md в
        репозитории курса.
      </p>
      <ul>
        <li>
          <code>GET /3/movie/popular?api_key=…&amp;language=ru-RU&amp;page=1</code>
        </li>
        <li>
          <code>GET /3/search/movie?api_key=…&amp;language=ru-RU&amp;query=…</code>
        </li>
        <li>
          <code>GET /t/p/w500/&lt;файл&gt;</code> — постеры
        </li>
      </ul>
      <p>
        <a href="/admin">Админка</a> — фильмы, изображения и API-ключи.
      </p>
    </main>
  )
}
