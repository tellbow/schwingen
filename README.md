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

## Deploying to Kubernetes

All manifests are in `k8s/`. The namespace is `schwingen`.

### Prerequisites

- A Kubernetes cluster
- `kubectl` configured
- Container images pushed to a registry (see [Build & Push](#push-images-to-registry) above)
- `nginx-ingress` and `cert-manager` installed in the cluster

### 1. Update image references

Edit `k8s/pocketbase-deployment.yaml` and `k8s/frontend-deployment.yaml` — replace `ghcr.io/OWNER/` with your actual registry path.

### 2. Configure secrets

Edit `k8s/secret.yaml` and set a real 32-character encryption key:

```yaml
stringData:
  PB_ENCRYPTION_KEY: "your-actual-32-char-encryption-key"
```

### 3. Configure the app

Edit `k8s/configmap.yaml` to set your domain and any OTEL settings:

```yaml
data:
  ORIGIN: "https://yourdomain.ch"
  OTEL_EXPORTER_OTLP_ENDPOINT: ""   # set if using OpenTelemetry
```

Update the hostname in `k8s/ingress.yaml`.

### 4. Apply manifests

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/pocketbase-pvc.yaml
kubectl apply -f k8s/pocketbase-deployment.yaml
kubectl apply -f k8s/pocketbase-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml
# Optional
kubectl apply -f k8s/frontend-hpa.yaml
kubectl apply -f k8s/pdb.yaml
```

Or apply the whole directory at once:

```bash
kubectl apply -f k8s/
```

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
