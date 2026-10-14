# Architecture Patterns

## Request Flow

- **Server-side load functions** (`+page.server.ts`) call PocketBase directly at `http://localhost:8090` via `createServerPb()`
- **Client-side calls** go through `/api/pb/[...path]` proxy to avoid CORS — use `getClientPb()`
- Both are exported from `src/lib/pb.ts` — never instantiate PocketBase directly

## PocketBase SDK Usage

```typescript
// Server (load functions, hooks)
import { createServerPb } from "$lib/pb";
const pb = createServerPb();
const wrestlers = await pb.collection("wrestler").getList(1, 15, { filter: "..." });

// Client (Svelte components, browser actions)
import { getClientPb } from "$lib/pb";
const pb = getClientPb();
```

Use `expand` to fetch related records in a single query — never make N+1 requests:

```typescript
pb.collection("rankings").getList(1, 15, { expand: "wrestler,place" });
```

## State Management (Svelte 5)

- Module-level `$state` in `.svelte.ts` files — **not** Svelte context
- Export a `getXState()` function to expose reactive state to components
- Export action functions (`loadX`, `fetchX`) separately from state
- Each store file owns one concern (e.g., dark mode, locale)

## Observability

- SvelteKit's own OpenTelemetry spans (`kit.experimental.tracing` in `svelte.config.js`): handle, load, resolve
- `src/instrumentation.server.ts` loads before the app: traces by OTLP when `OTEL_EXPORTER_OTLP_ENDPOINT` is set, Prometheus metrics on `METRICS_PORT` (9464 in the cluster, not routed by the ingress); `OTEL_SDK_DISABLED=true` turns both off
- `src/hooks.server.ts` records `http.server.request.duration` per route id
- The OpenTelemetry packages stay in `dependencies`: svelte-adapter-bun bundles devDependencies for the browser platform, which picks the OTLP exporter's fetch transport
- Health check at `/health`

## Routing

- Pages that need data use `+page.server.ts` (SSR load) + `+page.svelte` (render)
- API routes live under `src/routes/api/` and return `Response` objects
- The PocketBase proxy at `/api/pb/[...path]` must remain untouched
- `POST /api/bug-report` turns «Fehler melden» from the website and the app into issues in the private `tellbow/schwingen-feedback` (`$lib/server/bug-report.ts`: validation, screenshot stored in that repo, issue text, per-IP rate limit kept in memory per pod)

## Do Not

- Never start or restart dev processes — assume they are already running
- Never hardcode `localhost:8090` outside of `src/lib/pb.ts`
- Never read environment variables outside of `src/lib/pb.ts`, `src/hooks.server.ts`, `src/instrumentation.server.ts` or `src/routes/api/bug-report/+server.ts` (`GITHUB_FEEDBACK_TOKEN`, `GITHUB_FEEDBACK_REPO`)
- Never use Svelte context (`getContext`/`setContext`) for app-level state — use module `$state`
