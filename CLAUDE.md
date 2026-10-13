# CLAUDE.md – Project Context for Claude

**Project:** Tellbow – Alles rund ums Schwingen
**Purpose:** This file provides essential context for Claude when working on Tellbow.

---

## Project Overview

Tellbow is a **public Swiss Schwingen (wrestling) statistics dashboard**.

- Displays historical and current data about Swiss Schwingen competitions
- Wrestler profiles, rankings, bouts, places, clubs, cantons, and associations
- ELO ratings and statistical trends per year
- Fully public — no authentication, no user accounts, read-only data

---

## Tech Stack

- **Frontend:** SvelteKit 2.x, Svelte 5, TypeScript
- **UI Libraries:** TailwindCSS v4, lucide-svelte, shadcn-svelte (installed; Button, Input, Badge available)
- **Charts:** chart.js, chartjs-chart-geo, chartjs-plugin-datalabels, svelte-chartjs
- **PWA:** `vite-plugin-pwa` (service worker, offline caching)
- **Backend:** PocketBase binary only (no custom Go code)
- **Database:** SQLite (from PocketBase)
- **Auth:** None — fully public read-only app
- **Deployment:** Frontend & PocketBase Docker containers on **Kubernetes**, deployed by Flux from `tellbow/gitops` (`cluster/schwingen/`)
- **iOS app:** Flutter in `app/`, reads a release's `data.db` locally — see below

---

## Architecture Notes

### Data Model

Core collections:

- `wrestler` — Swiss wrestlers (name, club, canton, association, status)
- `places` — competition venues (name, placeType, location)
- `bouts` — individual wrestling bouts (wrestlers, result, event)
- `rankings` — official rankings entries
- `club` — wrestler clubs
- `canton` — Swiss cantons
- `association` — regional wrestling associations
- `status` — wrestler status/category
- `placeType` — type of competition venue

Year-indexed collections (replace `{year}` with e.g. `2025`):

- `elo{year}` — ELO ratings per wrestler per year
- `averageRank{year}` — average ranking per wrestler per year
- `averagePoints{year}` — average points per wrestler per year
- `mostWins{year}` — wrestlers with most wins per year
- `mostWreaths{year}` — wrestlers with most wreaths per year
- `mostPlacesAttended{year}` — attendance frequency per year
- `drawDecisionRatio` — ratio of draws vs. decisions (global)

The yearly views filter by date range (`places.year >= 'YYYY-01-01' AND places.year < 'YYYY+1-01-01'`, index `idx_places_year`), not `LIKE '%YYYY%'`, which scans all rankings. A new season's views copy the queries in `pb_migrations/1791887615_yearly_stats_views_by_date_range.js`.

Denormalized view collections:

- `wrestlersByAssociation`
- `wrestlersByCanton`
- `wrestlersByClub`

### Request Flow

- Server-side load functions call PocketBase directly at `localhost:8090`
- Client-side calls go through `/api/pb/[...path]` proxy (avoids CORS)
- `src/lib/pb.ts` — single PocketBase JS SDK client

### Observability

- SvelteKit's own OpenTelemetry spans (`kit.experimental.tracing` in `svelte.config.js`): handle, load, resolve
- `src/instrumentation.server.ts` loads before the app: traces by OTLP when `OTEL_EXPORTER_OTLP_ENDPOINT` is set, Prometheus metrics on `METRICS_PORT` (9464 in the cluster, not routed by the ingress); `OTEL_SDK_DISABLED=true` turns both off
- `src/hooks.server.ts` records `http.server.request.duration` per route id
- The OpenTelemetry packages stay in `dependencies`: svelte-adapter-bun bundles devDependencies for the browser platform, which picks the OTLP exporter's fetch transport
- Health check at `/health`

---

## PWA — Offline Caching

- Implemented with `vite-plugin-pwa`
- **Read-only app** — no offline write/sync needed
- Cache strategy: NetworkFirst for API requests, CacheFirst for static assets and images
- App shell and all static assets are precached on install

---

## Kubernetes Deployment

The app runs on **Kubernetes**. Keep this in mind when writing code:

- **No local state assumptions** — the PocketBase pod may restart; do not rely on in-process caches that survive restarts
- **Health endpoints** — ensure `/health` or `/api/health` exists for liveness/readiness probes
- **Environment config** — all config via environment variables (never hardcoded)
- **PocketBase data** — `pb_data/` must be on a **PersistentVolumeClaim**, not ephemeral container storage
- **Stateless frontend** — SvelteKit renders client-side only; the frontend container is fully stateless
- **Manifests live in `tellbow/gitops`**, not in this repo — see `.claude/rules/release-deployment.md`

### Releases and data

- Data is scraped and imported locally (`tellbow/schwingen-data` → local PocketBase), never in production
- A GitHub release `vX.Y.Z` with `data.db` attached by hand ships code and data together; its tag must be signed with a key in `.github/release-signers.asc`
- `.github/workflows/release.yml` verifies the tag, strips account/login records from the asset, attaches `app.db.gz` for the iOS app (`scripts/build-app-db.sh`), then pushes both images as `X.Y.Z` with SBOM, provenance and a cosign signature
- Flux bumps the deployments; the pocketbase initContainer downloads the latest release's `data.db` on start
- Production has no PocketBase superuser — the published `data.db` contains no accounts
- The `release` skill (`/release`) walks through a release step by step

---

## Development Guidelines

### Development Environment

- **Dev processes are always running in the background** — the user runs `bun run dev` themselves. Assume PocketBase and SvelteKit are already running. Do NOT start or restart them.
- PocketBase runs on port 8090, SvelteKit dev server on port 5173

### Development Commands

```bash
bun run dev     # Start PocketBase + SvelteKit concurrently (via start.ts)
bun run build   # Production build
bun run start   # Start production server (via start.ts --prod)
bun run lint    # Prettier check + ESLint
bun run format  # Prettier write
```

### iOS App (`app/`)

- Flutter, iOS only (`ch.tellbow.schwingen`), plain `StatefulWidget`/`setState`, DE/FR from `lib/l10n/app_{de,fr}.arb` (gen-l10n)
- Data: downloads the newest GitHub release's `app.db.gz` (only the tables and views the app reads, ~34 MB; `data.db` for releases without it) on first launch and opens it read-only with sqflite; later launches check for a newer release in the background (`lib/data/release.dart`, `store.dart`)
- All SQL lives in `lib/data/queries.dart`, on the PocketBase tables and views as they ship in the release — **a migration that renames or drops a column or view breaks the app**; run `TELLBOW_DB=<release data.db> flutter test test/release_database_test.dart` after schema changes
- Screens in `lib/screens/`: wrestlers, festivals (`places`), head-to-head, associations → cantons → clubs (`groups_screen.dart`), statistics; shared widgets in `widgets.dart` and `stat_grid.dart`, season trends (ELO, win rate, average points) in `trend_chart.dart` (fl_chart; series colour `seriesColor` in `theme.dart`, validated with the dataviz skill for light and dark), navigation and formatting in `context.dart`
- Queries: `queries.dart`, plus `group_queries.dart` and `statistics_queries.dart` (extensions on `Queries`); association counts are the app's own SQL, not the web's `wrestlersBy*` views (those use double-quoted strings and are not in `app.db`)
- Verify: `flutter analyze`, `flutter test` (in `app/`, also the `app` job in `ci.yml`); `integration_test/app_test.dart` drives the real app on a simulator
- Web lint (`bun run lint`) ignores `app/`; the Dart formatter (`page_width: 120`) applies there

### Claude Skills and Commands

- Commands (`.claude/commands/`): `/check` (lint, check, test, build), `/test`, `/test-file <path>`
- Skills (`.claude/skills/`):
  - `screenshot` — captures a state of the website (via `screenshot-capture`, Playwright on Haiku against the running dev server), shows it in the terminal and asks whether it fits. `.claude/rules/screenshots.md` says when: after every user-visible change
  - `release` — the release flow; only when the user asks for a release
  - `web-design-guidelines` — UI review against Vercel's Web Interface Guidelines; installed with `npx skills` (`.agents/skills/`, `skills-lock.json`), symlinked into `.claude/skills/`

---

### Code Style Guide

Follow these rules strictly to keep the codebase clean and consistent.

#### General Rules

- **No comments** in code — code should be self-explanatory
- **No dead code** — delete unused files, functions, imports, and variables immediately
- **No copy-paste** — extract shared logic into helpers/utils instead of duplicating
- **Keep it simple** — always pick the simplest solution that works
- **Read before writing** — understand existing patterns and context before implementing

#### File Size Limits

- **Svelte components:** max ~500 lines. Decompose into sub-components when larger.
- **TypeScript utils:** max ~300 lines. Extract shared logic into separate modules.
- If a file exceeds these limits, split it as part of the current task — don't leave it for later.

#### Frontend (SvelteKit / Svelte 5)

**File naming:**

- Components: `kebab-case.svelte`
- Stores: `kebab-case.svelte.ts`
- Utils: `kebab-case.ts`
- Tests: `{name}.test.ts` next to the file they test

**State management (Svelte 5 runes):**

- Module-level `$state` for stores — not Svelte context
- Export a `getXState()` function to expose reactive state
- Export action functions (`loadX`, `fetchX`) separately
- Each store owns one PocketBase collection

**Svelte 5 patterns:**

- Use `const foo = $derived(data.foo)` instead of destructuring props (avoids reactivity warning)
- Canvas bindings need `$state<HTMLCanvasElement | null>(null)`
- Use `<button>` instead of `<li onclick>` or `<span onclick>` for accessibility
- `{@render children()}` in layouts (slot replacement)
- Props use Svelte 5 `$props()` rune

**Shared logic:**

- Pure utility functions go in `src/lib/utils/`
- If the same calculation exists in multiple places, extract it to utils immediately

**Component structure:**

- Group components by domain: `wrestler/`, `rankings/`, `bouts/`, `places/`, `associations/`
- Large components should be decomposed into orchestrator + sub-components
- `src/lib/components/Header.svelte` and `Footer.svelte` are global layout components

**Imports:**

- shadcn-svelte: import from `$lib/components/ui/`
- Icons: import from `lucide-svelte`
- Charts: `import { Chart } from "svelte-chartjs"` and chart.js registrations as needed
- PocketBase client: `import pb from "$lib/pb"`

**Internationalisation (DE/FR — implemented):**

- Custom i18n system — no external library
- Translation files: `src/lib/i18n/translations.ts` (structured `de`/`fr` objects), `src/lib/i18n/index.svelte.ts` (`t`, `LOCALES`, `localizePath`, `delocalizePath`)
- Locale comes from the URL: German has no prefix, French lives under `/fr/...`. `src/hooks.ts` reroutes `/fr/...` to the same route, `src/hooks.server.ts` sets `locals.locale` and the page's `lang`, `+layout.server.ts` passes `locale` as page data
- Usage: `const locale = $derived($page.data.locale as Locale)` (or `data.locale`), then `t(locale, "section.key")`
- Links: `localizePath(href, locale)`; switching language is a link to the other locale's URL — nothing is stored in `localStorage`
- Date/number formatting via `Intl.DateTimeFormat` / `Intl.NumberFormat`
- Format helpers live in `src/lib/utils/format.ts`
- **Current state:** DE/FR fully implemented. DE is the default locale.

#### Testing

**Always write tests for:**

- New utility functions and pure logic
- Bug fixes (regression test)

**Frontend tests:**

- Use Vitest + jsdom
- Test files live next to source: `filter.test.ts` beside `filter.ts`

**Verification after every change:**

```bash
bun run lint    # Prettier + ESLint
bun run check   # TypeScript/Svelte type checking
bun run build   # Verify production build succeeds
```

---

### Project Structure

```text
/
├── start.ts                 # Dev/prod process launcher (Bun)
├── package.json
├── svelte.config.js
├── vite.config.ts
├── pb_data/                 # PocketBase data (gitignored, must be on PVC in k8s)
├── src/
│   ├── app.html
│   ├── app.css
│   ├── lib/
│   │   ├── pb.ts            # PocketBase JS SDK client
│   │   ├── components/
│   │   │   ├── Header.svelte
│   │   │   └── Footer.svelte
│   │   └── utils/
│   │       └── filter.ts    # Shared filtering logic
│   └── routes/
│       ├── +layout.svelte
│       ├── +page.svelte     # Home/landing
│       ├── api/pb/[...path]/  # CORS proxy to PocketBase
│       ├── wrestler/
│       ├── rankings/
│       ├── bouts/
│       ├── places/
│       ├── associations/
│       ├── head2head/
│       └── statistics/
├── static/
│   ├── favicon.ico
│   └── topo/                # GeoJSON for map charts
├── pb_migrations/           # PocketBase migrations, baked into the pocketbase image
├── scripts/                 # strip-auth-records.sh, swap-pocketbase-db.sh, build-app-db.sh
├── docker/                  # frontend/ and pocketbase/ Dockerfiles
├── docker-compose.yml
├── app/                     # Flutter iOS app (local SQLite from a release's data.db)
└── .github/workflows/       # ci.yml (push/PR/weekly: lint, tests, app, osv-scanner, zizmor, gitleaks, semgrep), release.yml (published release)
```

### Key Principles

1. **Public read-only dashboard:** no auth, no user state, no writes from the frontend
2. **Stateless frontend:** SvelteKit renders client-side only
3. **Kubernetes-ready:** stateless containers, env-var config, health endpoints
4. **Multi-language:** DE/FR implemented — use `t(locale, "key")` from `$lib/i18n/index.svelte` for all UI strings
