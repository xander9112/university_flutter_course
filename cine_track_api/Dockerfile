# CineTrack API (Payload CMS + Next.js). Сборка из этой папки:
#   docker build -t cinetrack-api .
# или из корня репозитория курса: ./deploy.sh api
# Next.js собирается в output: 'standalone' (next.config.ts): в рантайм-образ попадает
# только server.js и трассированный node_modules.

FROM node:22-alpine AS base
RUN corepack enable

# 1. Зависимости — отдельным слоем: кэшируется, пока не меняются package.json и lock-файл
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

# 2. Сборка
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
# Настоящие значения на сборке не нужны (к базе Payload подключается лениво, при первом
# запросе), но buildConfig требует непустой secret. Реальные DATABASE_URL и PAYLOAD_SECRET
# задаются при запуске (docker-compose.yml / portainer-stack.yml) и в образ не попадают.
ARG DATABASE_URL=postgresql://build:build@localhost:5432/build
ARG PAYLOAD_SECRET=build-time-placeholder
ENV DATABASE_URL=$DATABASE_URL
ENV PAYLOAD_SECRET=$PAYLOAD_SECRET
RUN pnpm run build

# 3. Рантайм
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
# Загруженные постеры — в volume, иначе они пропадут при пересоздании контейнера
ENV MEDIA_DIR=/app/media
RUN mkdir -p /app/media && chown nextjs:nodejs /app/media
VOLUME /app/media
USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
# Миграции схемы (src/migrations) применяются автоматически при старте — отдельного шага нет
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:3000/health || exit 1
CMD ["node", "server.js"]
