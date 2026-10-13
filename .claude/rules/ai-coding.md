# AI Coding Conventions

## Predictable File Locations

Every piece of logic has exactly one canonical home:

| What | Where |
|------|-------|
| Types/interfaces | `$lib/types/*.ts` |
| Pure utilities | `$lib/utils/<concern>.ts` |
| PocketBase filter helpers | `$lib/utils/filter.ts` |
| i18n translations | `$lib/i18n/translations.ts` |
| i18n reactive state | `$lib/i18n/index.svelte.ts` |
| Reactive stores | `$lib/<name>.svelte.ts` |
| UI primitives | `$lib/components/ui/<component>/` |
| Domain components | `$lib/components/<domain>/` |
| Global layout components | `$lib/components/Header.svelte`, `Footer.svelte` |
| Page-specific logic | stays in the page file; extract to `$lib/utils/` when reused |

## Self-Documenting Code

No comments — code must be discoverable by name:

- **Function names describe behavior**: `buildFilterString`, `validateRouteParam`, `escapeFilterValue`
- **File names describe contents**: `filter.ts` contains filter helpers, `dark-mode.svelte.ts` contains dark mode state
- **One concept per file**: don't mix unrelated concerns
- **Exports at the top**: put the main exported function/type at the top of the file

## Change Verification Checklist

After every code change, verify:

```bash
bun run lint    # Prettier + ESLint
bun run check   # TypeScript/Svelte type checking
bun run test    # Vitest unit tests
bun run build   # Production build succeeds
```

## When Adding a New Feature

1. **Define types first** — add to `$lib/types/`
2. **Implement utilities** — add to `$lib/utils/<concern>.ts`
3. **Add translations** — add DE and FR keys to `$lib/i18n/translations.ts`
4. **Implement the route/component** — use existing utilities and components
5. **Write tests** — for every new utility function, alongside the source file
6. **Verify** — run the checklist above

## When Modifying Existing Code

1. **Read the whole file first** — understand the existing pattern before changing it
2. **Check for callers** — grep for the function name to find all usage sites
3. **Update all call sites** — if you change a signature, update every caller
4. **Check for duplicates** — if your change creates a pattern that exists elsewhere, extract a shared utility
5. **Update tests** — every modified function must have updated tests

## File Size Discipline

Check file sizes after every change. If a file exceeds its limit, split it in the same task:

- Svelte components: max 500 lines
- TypeScript utils: max 300 lines
- Page files (routes): max 800 lines
