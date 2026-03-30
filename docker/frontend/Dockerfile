# syntax=docker/dockerfile:1
# ---------- build stage ----------
FROM oven/bun:1.3-alpine AS builder
WORKDIR /app

# Install deps first (layer cache)
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy source and build
COPY . .
RUN bun run build

# ---------- runtime stage ----------
FROM oven/bun:1.3-alpine AS runner
WORKDIR /app

# Only copy what the server needs at runtime
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./

# Install production deps only (pocketbase SDK, etc.)
RUN bun install --production --frozen-lockfile 2>/dev/null || bun install --production

ENV PORT=3000
ENV HOST=0.0.0.0
EXPOSE 3000

CMD ["bun", "run", "build/index.js"]
