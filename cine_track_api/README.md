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

## Деплой

Образы собираются на Mac и публикуются в registry `registry.xander9112.keenetic.link`, сервер скачивает их оттуда и запускает стек в Portainer. Публикация идёт в два захода — сначала API, потом веб-версия: в веб-версию встраивается API-ключ, а его выдаёт уже работающий API.

Нужно на Mac:

- запущенный Docker Desktop с доступом к registry: если push просит авторизацию — `docker login registry.xander9112.keenetic.link`;
- Node и Flutter.

Все команды — из **корня репозитория курса**, в любой ветке: `deploy.sh` есть во всех.

### 1. Опубликовать API

```bash
./deploy.sh api
```

Соберётся и отправится образ `registry.xander9112.keenetic.link/cinetrack-api:<version>`, версия — из `cine_track_api/package.json`. Сборка под `linux/amd64` на Mac с Apple Silicon идёт через эмуляцию и занимает около 5 минут.

> Если push падает с `404` на загрузке слоёв (реверс-прокси registry ломал push у hepatool), отправьте образ напрямую — это то же хранилище: `REGISTRY=192.168.1.150:5000 ./deploy.sh api`.

### 2. Создать стек в Portainer

1. **Stacks → Add stack → Web editor**, вставить содержимое [portainer-stack.yml](../portainer-stack.yml).
2. **Environment variables**:

   | Переменная | Значение |
   |---|---|
   | `POSTGRES_PASSWORD` | любой пароль базы |
   | `PAYLOAD_SECRET` | длинная случайная строка: `openssl rand -base64 32`; подписывает сессии админки, при смене все входы сбрасываются |
   | `TMDB_IMPORT_API_KEY` | необязательно — ключ TMDB для кнопки импорта фильмов |

3. Сервис `web` при первом запуске закомментируйте — его образа ещё нет.
4. **Deploy the stack**.

### 3. Настроить Nginx Proxy Manager для API

Proxy Host, например `cinetrack-api.<домен>`: порт **5200** на сервере, во вкладке SSL — сертификат Let's Encrypt и Force SSL. HTTPS обязателен: приложение на Android и iOS по обычному HTTP не ходит.

Нужен **отдельный (под)домен целиком**, не подпуть: API (`/3`), картинки (`/t/p`), админка (`/admin`) и её ресурсы (`/_next`, `/api`) лежат в разных путях от корня.

Проверка: `https://cinetrack-api.<домен>/health` отвечает `ok`.

### 4. Наполнить API

1. `https://cinetrack-api.<домен>/admin` — создать первого пользователя (администратора).
2. **API-ключи → Создать** — например «Курс 2026», скопировать значение ключа.
3. **Фильмы** — добавить вручную или нажать «Импортировать популярные из TMDB» (нужен `TMDB_IMPORT_API_KEY`).

```bash
curl "https://cinetrack-api.<домен>/3/movie/popular?api_key=<ключ>&language=ru-RU&page=1"
```

### 5. Опубликовать веб-версию

```bash
CINETRACK_API_URL=https://cinetrack-api.<домен> \
CINETRACK_API_KEY=<ключ из шага 4> \
./deploy.sh web
```

Скрипт соберёт Flutter из ветки `lesson_21` во временной копии (другая ветка — `WEB_BRANCH=...`) с адресом API и ключом и отправит образ `registry.xander9112.keenetic.link/cinetrack-web:<version>`, версия — из `cine_track/pubspec.yaml` (`1.0.0+1` → `1.0.0-1`).

### 6. Включить веб-версию

1. В Portainer раскомментировать `web`, проверить теги образов — **Update the stack**.
2. В Nginx Proxy Manager — второй Proxy Host, например `cinetrack.<домен>`: порт **5210**, сертификат Let's Encrypt.

Приложение откроется на `https://cinetrack.<домен>`.

### Обновления

| Что изменилось | Что сделать |
|---|---|
| код API | поднять `version` в `cine_track_api/package.json` → `./deploy.sh api` → новый тег `cinetrack-api` в стеке → **Update the stack**. Миграции базы применятся сами при старте |
| приложение, адрес API или ключ | `./deploy.sh web` с теми же переменными → обновить стек. Если `version` в `pubspec.yaml` не менялась, тег тот же — включите **Re-pull image** при обновлении |

Если ключ, встроенный в веб-версию, отключить или удалить в админке, веб-версия перестанет загружать фильмы — пересоберите её с новым ключом.

Данные — в volume стека: `cinetrack_db_data` (база) и `cinetrack_media` (постеры). Обновление образов их не трогает.

## Подключение студентов

Студенты собирают приложение с адресом сервера и общим ключом, без регистрации на TMDB:

```bash
flutter run \
  --dart-define=TMDB_API_KEY=ключ_курса \
  --dart-define=TMDB_BASE_URL=https://cinetrack-api.example.com/3 \
  --dart-define=TMDB_IMAGE_BASE_URL=https://cinetrack-api.example.com/t/p/w500
```

`--dart-define` для адресов поддерживает приложение из ветки `lesson_21`. В Заданиях 11–20 адрес пока записан в коде константой — какие места поменять, перечислено в разделе 9 [API.md](../API.md).
