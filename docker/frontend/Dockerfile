# syntax=docker/dockerfile:1
# The build output is plain JavaScript: build natively, run on any platform.
FROM --platform=$BUILDPLATFORM oven/bun:1.3-alpine AS builder
WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
ARG APP_VERSION=dev
RUN bun run build \
 && rm -rf node_modules \
 && bun install --frozen-lockfile --production

# svelte-adapter-bun bundles the devDependencies into build/; the
# dependencies (OpenTelemetry, pocketbase, …) come as node_modules.
FROM oven/bun:1.3-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=3000 HOST=0.0.0.0
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY package.json ./
USER bun
EXPOSE 3000

CMD ["bun", "run", "build/index.js"]
