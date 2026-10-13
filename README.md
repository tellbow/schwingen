# Tellbow – Alles rund ums Schwingen

Tellbow is a public Swiss Schwingen (wrestling) statistics dashboard. It displays historical and current data about Swiss Schwingen competitions: wrestler profiles, rankings, bouts, venues, clubs, cantons, associations, ELO ratings, and statistical trends.

Live at **[tellbow.ch](https://tellbow.ch)**

---

## Tech Stack

- **Frontend:** SvelteKit 2.x + Svelte 5, TypeScript, Tailwind CSS v4
- **Backend:** [PocketBase](https://pocketbase.io/) (SQLite)
- **Runtime:** [Bun](https://bun.sh/)
- **Charts:** chart.js, chartjs-chart-geo
- **PWA:** offline-capable via vite-plugin-pwa

---

## Running Locally (Bun)

### Prerequisites

- [Bun](https://bun.sh/) >= 1.0
- [PocketBase](https://pocketbase.io/docs/) binary available as `pocketbase` in your PATH (or at `/opt/homebrew/bin/pocketbase`)

### Setup

```bash
bun install
```

### Development

```bash
bun run dev
```

This starts both PocketBase (port 8090) and the SvelteKit dev server (port 5173) via `start.ts`.

Open [http://localhost:5173](http://localhost:5173).

### Other commands

```bash
bun run build   # Production build
bun run start   # Start production server (port 3000)
bun run check   # TypeScript/Svelte type checking
bun run test    # Run tests
```

---

## Running with Docker

### Prerequisites

- Docker with Compose

### Environment

Create a `.env` file:

```env
PB_ENCRYPTION_KEY=your-32-character-encryption-key
ORIGIN=http://localhost:3000
```

### Start

```bash
docker compose up --build
```

Or via Make:

```bash
make up
```

This starts:

- **PocketBase** on port 8090 (`pb_data/` is mounted from `./pb_data`)
- **Frontend** on port 3000

Open [http://localhost:3000](http://localhost:3000).

### Stop

```bash
docker compose down
# or
make down
```

### Build images only

```bash
make docker-build
```

### Push images to registry

```bash
# Defaults to ghcr.io/<your-github-username>/
make docker-push

# Override registry/owner/tag
make docker-push REGISTRY=ghcr.io OWNER=myorg TAG=v1.2.3
```

---

## Releasing and Deploying

The app runs on Kubernetes, deployed by Flux from [`tellbow/gitops`](https://github.com/tellbow/gitops) (`cluster/schwingen/`). Manifests live there, not in this repo.

A release ships code and data together:

1. Update the data locally (see [`tellbow/schwingen-data`](https://github.com/tellbow/schwingen-data)) and commit any code changes to `main`.
2. Create a GitHub release with a new tag `vX.Y.Z` and attach `pb_data/data.db` as `data.db`.
3. The `release` workflow strips all account and login records from the attached `data.db` and replaces the asset (`scripts/strip-auth-records.sh`), then pushes `ghcr.io/tellbow/schwingen-frontend:X.Y.Z` and `schwingen-pocketbase:X.Y.Z`.
4. Flux image automation bumps both deployments to `X.Y.Z`. On start, the pocketbase pod's initContainer downloads the latest release's `data.db` if it differs from the one on the PVC, and keeps the previous one as `data.db.previous`.

Run `./scripts/strip-auth-records.sh` on a copy before uploading so the asset is never public with accounts in it, even for the minute before the workflow replaces it.

### Architecture

```
Internet → nginx Ingress → frontend (2 replicas, port 3000)
                                   ↓ /api/pb/* proxy
                           pocketbase (1 replica, port 8090)
                                   ↓
                           PersistentVolumeClaim (SQLite data)
```

PocketBase uses a `Recreate` deployment strategy because the PVC is `ReadWriteOnce`. The frontend is stateless and scales horizontally.

### Health endpoints

- Frontend: `GET /health`
- PocketBase: `GET /api/health`
