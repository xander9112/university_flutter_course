#!/usr/bin/env bash
# Сборка и публикация Docker-образов CineTrack в registry. По образцу hepatool_admin/deploy.sh.
#
# Использование:
#   ./deploy.sh api [доп. аргументы docker build]   # cine_track_api (Payload CMS)
#   ./deploy.sh web                                 # веб-версия cine_track (Flutter → nginx)
#
# Версия образа:
#   api — поле "version" из cine_track_api/package.json   → cinetrack-api:1.0.0
#   web — поле version из cine_track/pubspec.yaml ветки    → cinetrack-web:1.0.0-1
#         WEB_BRANCH («+» в теге Docker недопустим, заменяется на «-»)
# После публикации обновите теги в portainer-stack.yml.
#
# Переменные окружения:
#   REGISTRY   — куда пушить (по умолчанию 192.168.1.150:5000 — напрямую по IP: реверс-прокси
#                registry.xander9112.keenetic.link ломает push новых блобов; pull через домен
#                работает, поэтому portainer-stack.yml ссылается на домен)
#   PLATFORM   — платформа образа (по умолчанию linux/amd64 — архитектура сервера; сборка идёт
#                на Mac с Apple Silicon, без явной платформы получится linux/arm64 и контейнер
#                на сервере упадёт с "exec format error")
#
# Только для web — адрес API и ключ встраиваются в сборку Flutter (--dart-define):
#   CINETRACK_API_URL  — адрес cine_track_api без слэша в конце, например https://cinetrack-api.example.com
#   CINETRACK_API_KEY  — ключ из админки API (коллекция «API-ключи»)
#   WEB_BRANCH         — ветка, из которой собирается приложение (по умолчанию lesson_21 —
#                        финальная версия курса)

set -euo pipefail

REGISTRY="${REGISTRY:-192.168.1.150:5000}"
PLATFORM="${PLATFORM:-linux/amd64}"
WEB_BRANCH="${WEB_BRANCH:-lesson_21}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

usage() {
  sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
}

require_docker() {
  if ! docker info >/dev/null 2>&1; then
    echo "Docker недоступен (демон не отвечает). Запустите Docker Desktop и повторите." >&2
    exit 1
  fi
}

# --provenance=false --sbom=false: реестр за реверс-прокси неверно обрабатывает
# attestation-манифесты BuildKit (push падает с 404), обычные слои это не задевает
build_and_push() {
  local image="$1"
  shift
  echo "==> Сборка $image для $PLATFORM"
  docker build --platform "$PLATFORM" --provenance=false --sbom=false -t "$image" "$@"
  echo "==> Push $image"
  docker push "$image"
  echo "==> Готово: $image"
}

deploy_api() {
  local version
  version="$(node -p "require('./cine_track_api/package.json').version")"
  build_and_push "$REGISTRY/cinetrack-api:$version" "$@" cine_track_api
}

deploy_web() {
  : "${CINETRACK_API_URL:?Задайте CINETRACK_API_URL, например https://cinetrack-api.example.com}"
  : "${CINETRACK_API_KEY:?Задайте CINETRACK_API_KEY — ключ из админки API}"
  local api_url="${CINETRACK_API_URL%/}"

  if ! git rev-parse --verify --quiet "$WEB_BRANCH" >/dev/null; then
    echo "Нет ветки $WEB_BRANCH" >&2
    exit 1
  fi

  # Приложение собирается из WEB_BRANCH во временной копии (git worktree) — текущая ветка
  # и незакоммиченные изменения рабочей папки не важны
  local worktree
  worktree="$(mktemp -d)"
  trap 'git -C "$ROOT" worktree remove --force "'"$worktree"'" >/dev/null 2>&1 || true' EXIT
  git worktree add --detach "$worktree" "$WEB_BRANCH" >/dev/null

  local app="$worktree/cine_track"
  local version
  version="$(sed -n 's/^version: *//p' "$app/pubspec.yaml" | tr '+' '-')"

  echo "==> flutter build web из $WEB_BRANCH (API: $api_url)"
  (
    cd "$app"
    flutter pub get >/dev/null
    # --no-web-resources-cdn: CanvasKit раздаётся с нашего сервера, а не с gstatic.com
    flutter build web --release --no-web-resources-cdn \
      --dart-define=TMDB_API_KEY="$CINETRACK_API_KEY" \
      --dart-define=TMDB_BASE_URL="$api_url/3" \
      --dart-define=TMDB_IMAGE_BASE_URL="$api_url/t/p/w500"
  )

  build_and_push "$REGISTRY/cinetrack-web:$version" \
    --build-context web="$app/build/web" cine_track_web
}

[[ $# -ge 1 ]] || usage
TARGET="$1"
shift

require_docker
case "$TARGET" in
  api) deploy_api "$@" ;;
  web) deploy_web ;;
  *) usage ;;
esac
