# Веб-версия CineTrack: nginx отдаёт готовую сборку Flutter (flutter build web) и проксирует
# пути API (/3, /t/p, /admin, /api, /_next) в cine_track_api — веб-версия и админка на одном
# домене (см. default.conf.template).
# Сборку делает ./deploy.sh web и передаёт её как именованный контекст `web`:
#   docker build --build-context web=<путь к cine_track/build/web> -t cinetrack-web cine_track_web
# Flutter внутри Docker не собирается: сборка под linux/amd64 на Mac с Apple Silicon шла бы
# через эмуляцию и занимала бы десятки минут.

FROM nginx:1.29-alpine
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=web . /usr/share/nginx/html
# Адрес cine_track_api внутри сети стека (имя сервиса в portainer-stack.yml)
ENV API_UPSTREAM=http://api:3000
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/health || exit 1
