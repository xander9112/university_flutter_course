# CineTrack API

TMDB-совместимый сервер для учебного приложения CineTrack на [Payload CMS](https://payloadcms.com) 3 и Postgres. Студентам не нужно регистрироваться на themoviedb.org: приложение ходит сюда с общим ключом курса. Формат API описан в [API.md](../API.md) в корне репозитория.

| Путь | Что |
|---|---|
| `GET /3/movie/popular?api_key=…&language=ru-RU&page=1` | популярные фильмы, по 20 на страницу |
| `GET /3/search/movie?api_key=…&language=ru-RU&query=…` | поиск по названию и оригинальному названию |
| `GET /t/p/w500/<файл>`, `/t/p/original/<файл>` | постеры (CORS включён) |
| `/admin` | админка на русском: фильмы, изображения, API-ключи, пользователи |
| `GET /health` | проверка для Docker: сервер и база доступны |

## Содержимое админки

- **Фильмы**:
  - название и оригинальное название — по обоим работает поиск;
  - описание, постер и фоновый кадр, дата `ГГГГ-ММ-ДД`, рейтинг 0–10, жанры;
  - «Популярность» — порядок в `/3/movie/popular`, чем больше, тем выше;
  - «Опубликован» — снятый флажок скрывает фильм из API.
- **Импорт из TMDB.** Кнопка над списком фильмов загружает популярные фильмы с постерами из настоящего TMDB. Нужен ключ TMDB преподавателя в `TMDB_IMPORT_API_KEY`, студентам ключ TMDB не нужен. Повторный импорт обновляет уже загруженные фильмы по `tmdbId` и не скачивает картинки заново. Флажок «Опубликован» импорт не трогает.
- **API-ключи** — значения для `api_key`. Ключ генерируется при создании, его можно задать вручную. Отключённый ключ получает `401`; кэш проверки ключа — 30 секунд.
- **Пользователи** — администраторы. Первого пользователя создают на `/admin` при первом входе, остальных добавляют вошедшие администраторы. Регистрации нет.

## Локальная разработка

```bash
cp .env.example .env              # задайте PAYLOAD_SECRET
docker compose up -d db           # Postgres на localhost:5434
pnpm install
pnpm dev                          # http://localhost:3000/admin
```

В dev-режиме схема базы синхронизируется с коллекциями автоматически. В production — только через миграции из `src/migrations`: они применяются при старте сервера. Поэтому после изменения коллекций:

```bash
pnpm payload migrate:create <название>   # против dev-базы, уже синхронизированной pnpm dev
pnpm generate:types                      # src/payload-types.ts
pnpm generate:importmap                  # если добавлены или изменены компоненты админки
pnpm typecheck
```

## Запуск в Docker

```bash
cp .env.example .env   # PAYLOAD_SECRET обязателен
docker compose up -d --build
```

- Админка: http://localhost:5200/admin.
- API: http://localhost:5200/3/movie/popular?api_key=….

Постеры хранятся в volume `cinetrack_media` (`/app/media`), база — в `cinetrack_db_data`.

Проверка API:

```bash
K=ключ_из_админки
curl "http://localhost:5200/3/movie/popular?api_key=$K&language=ru-RU&page=1"
curl "http://localhost:5200/3/search/movie?api_key=$K&language=ru-RU&query=%D0%9C%D0%B0%D1%82%D1%80%D0%B8%D1%86%D0%B0"
```

## Публикация на сервер

Из корня репозитория курса, на Mac с запущенным Docker:

```bash
./deploy.sh api                      # → cinetrack-api:<version из package.json>

CINETRACK_API_URL=https://cinetrack-api.example.com \
CINETRACK_API_KEY=ключ_из_админки \
./deploy.sh web                      # → cinetrack-web:<version из pubspec.yaml>
```

Веб-версия собирается из ветки `lesson_21` (переменная `WEB_BRANCH`), адрес API и ключ встраиваются в неё при сборке. Сначала опубликуйте и настройте API, создайте в админке ключ, потом собирайте веб-версию.

На сервере стек запускается в Portainer из [portainer-stack.yml](../portainer-stack.yml):
- переменные стека — `POSTGRES_PASSWORD`, `PAYLOAD_SECRET`, при желании `TMDB_IMPORT_API_KEY`;
- после каждого `./deploy.sh` обновите там теги образов.

В Nginx Proxy Manager нужно два хоста, оба с HTTPS: приложение на Android и iOS не ходит по обычному HTTP.

| Домен | Порт | Важно |
|---|---|---|
| `cinetrack-api.example.com` | 5200 | весь домен целиком: API (`/3`), картинки (`/t/p`), админка (`/admin`) и её ресурсы (`/_next`, `/api`) лежат в разных путях от корня |
| `cinetrack.example.com` | 5210 | веб-версия |

## Подключение студентов

Студенты собирают приложение с адресом сервера и общим ключом, без регистрации на TMDB:

```bash
flutter run \
  --dart-define=TMDB_API_KEY=ключ_курса \
  --dart-define=TMDB_BASE_URL=https://cinetrack-api.example.com/3 \
  --dart-define=TMDB_IMAGE_BASE_URL=https://cinetrack-api.example.com/t/p/w500
```

`--dart-define` для адресов поддерживает приложение из ветки `lesson_21`. В Заданиях 11–20 адрес пока записан в коде константой — какие места поменять, перечислено в разделе 9 [API.md](../API.md).
