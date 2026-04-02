# Frontend Testing Patterns

## Framework

- **Vitest** with jsdom environment (configured in `vite.config.ts`)
- Test files: `<source>.test.ts` alongside the source file
- Test glob: `src/**/*.test.ts`

## Structure

```typescript
import { describe, it, expect, vi } from "vitest";

describe("functionName", () => {
  it("handles the success case", () => {
    // arrange, act, assert
  });

  it("handles the error case", () => {
    // arrange, act, assert
  });
});
```

## Mocking

- `vi.mock("module")` for module-level mocks
- `vi.fn()` for function spies and stubs
- `vi.spyOn(object, "method")` for method spies
- Mock `localStorage` via `vi.spyOn(window.localStorage, "getItem")`

## SvelteKit Modules

Mock SvelteKit modules inline when needed:

```typescript
vi.mock("$app/environment", () => ({ browser: true }));
```

## What to Test

- Pure utility functions — `$lib/utils/filter.ts`, `$lib/utils.ts` (no mocks needed)
- i18n structure — `$lib/i18n/translations.ts` (key completeness between DE/FR)
- State management logic — reactive stores in `.svelte.ts` files
- Data transformation and formatting helpers

## File Naming

- `src/lib/utils/filter.test.ts` — tests for `filter.ts`
- `src/lib/utils.test.ts` — tests for `utils.ts`
- `src/lib/i18n/translations.test.ts` — tests for translation completeness
