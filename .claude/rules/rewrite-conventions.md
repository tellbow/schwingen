# File Organization & Decomposition

## Hard Limits

- **Svelte components** (`$lib/components/`): max 500 lines
- **Svelte page files** (`routes/`): max 800 lines — extract logic into `$lib/` when approaching
- **TypeScript utilities**: max 300 lines

When a file exceeds its limit, split it immediately as part of the current task.

## Frontend File Map

### Shared library (`src/lib/`)

| File | Purpose | Exports |
|------|---------|---------|
| `pb.ts` | PocketBase client | `createServerPb()`, `getClientPb()` |
| `utils.ts` | General utilities | `cn()` (Tailwind class merging), `WithElementRef<T>` |
| `dark-mode.svelte.ts` | Dark mode state | reactive state, toggle, init functions |

### Utils (`src/lib/utils/`)

| File | Purpose | Exports |
|------|---------|---------|
| `filter.ts` | PocketBase filter helpers | `escapeFilterValue()`, `buildFilterString()`, `validateRouteParam()` |
| `bug-report.ts` | Sending «Fehler melden» from the browser | `sendBugReport()`, `reportPlace()` |
| `page-screenshot.ts` | The whole page as a JPEG for a bug report (lazy `html-to-image`) | `pageScreenshot()`, `screenshotBase64()`, `MAX_SCREENSHOT_BYTES` |

### Server only (`src/lib/server/`)

| File | Purpose | Exports |
|------|---------|---------|
| `bug-report.ts` | Bug report validation, screenshot storage, issue text, GitHub calls, rate limit | `parseBugReport()`, `parseScreenshot()`, `isHoneypotFilled()`, `issueTitle()`, `issueBody()`, `openIssue()`, `storeScreenshot()`, `RateLimiter` |

### i18n (`src/lib/i18n/`)

| File | Purpose | Exports |
|------|---------|---------|
| `translations.ts` | DE/FR translation strings | `de`, `fr` translation objects |
| `index.svelte.ts` | Translation lookup and locale URLs (French under `/fr`) | `t()`, `LOCALES`, `localizePath()`, `delocalizePath()`, `Locale` |

### Components (`src/lib/components/`)

| File/Dir | Purpose |
|----------|---------|
| `Header.svelte` | Global nav header (logo, nav links, locale selector, dark mode toggle) |
| `Footer.svelte` | Global footer |
| `ui/button/` | shadcn-svelte Button primitive |
| `ui/input/` | shadcn-svelte Input primitive |
| `ui/badge/` | shadcn-svelte Badge primitive |

### Before creating a new file

1. Check this file map — does an existing file already cover this concern?
2. Check `$lib/utils/` — is there already a utility for this pattern?
3. Check `$lib/types/` — is this type already defined?

## Routes Structure

```
src/routes/
├── +layout.svelte          # Root layout (Header, Footer, locale init, dark mode init)
├── +page.svelte            # Home/landing
├── api/
│   ├── pb/[...path]/       # CORS proxy to PocketBase — do not modify
│   └── bug-report/         # «Fehler melden» → GitHub issue
├── health/                 # Health check endpoint
├── sitemap.xml/            # SEO sitemap
├── wrestler/               # Wrestler list + [id]/ detail
├── rankings/               # Rankings list + [id]/ detail
├── bouts/                  # Bout history list
├── places/                 # Competition venues list
├── associations/           # Associations overview
│   ├── association/[id]/   # Association detail
│   ├── canton/[id]/        # Canton detail
│   └── club/[id]/          # Club detail
├── head2head/              # Head-to-head comparison + [wid]-[oid]/ detail
└── statistics/             # Statistical dashboards
```

## Thin Layers

- **Page load functions** (`+page.server.ts`): query PocketBase → return data. No business logic beyond query construction.
- **Svelte pages**: orchestrate components, manage local state, call load data. Extract reusable logic to `$lib/utils/`.
- **API routes** (`+server.ts`): validate → process → return Response. Keep thin.
