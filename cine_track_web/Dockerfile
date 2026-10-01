# Веб-версия CineTrack: nginx отдаёт готовую сборку Flutter (flutter build web).
# Сборку делает ./deploy.sh web и передаёт её как именованный контекст `web`:
#   docker build --build-context web=<путь к cine_track/build/web> -t cinetrack-web cine_track_web
# Flutter внутри Docker не собирается: сборка под linux/amd64 на Mac с Apple Silicon шла бы
# через эмуляцию и занимала бы десятки минут.

FROM nginx:1.29-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=web . /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/health || exit 1
