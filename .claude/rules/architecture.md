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

- `src/lib/metrics.ts` — Prometheus metrics (HTTP request counters + duration histograms)
- `src/lib/tracing.ts` — OpenTelemetry NodeSDK with OTLP HTTP exporter
- Both wired in `src/hooks.server.ts` — do not modify the instrumentation setup
- Metrics available at `/metrics`, health check at `/health`

## Routing

- Pages that need data use `+page.server.ts` (SSR load) + `+page.svelte` (render)
- API routes live under `src/routes/api/` and return `Response` objects
- The PocketBase proxy at `/api/pb/[...path]` must remain untouched

## Do Not

- Never start or restart dev processes — assume they are already running
- Never hardcode `localhost:8090` outside of `src/lib/pb.ts`
- Never read environment variables outside of `src/lib/pb.ts` or `src/hooks.server.ts`
- Never use Svelte context (`getContext`/`setContext`) for app-level state — use module `$state`
