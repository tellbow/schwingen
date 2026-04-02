# Testing Rules

When creating or modifying any TypeScript or Svelte source file that contains logic, always create or update the corresponding test file.

## Requirements

- Every new utility function or pure logic must have tests
- Tests must cover success paths, error paths, and edge cases
- Test files live alongside their source files (`.test.ts`)
- Mock at infrastructure boundaries (PocketBase SDK, localStorage, `$app/environment`) — never mock in-process logic
- Run `bun run test` after writing tests to verify they pass
- Use `describe`/`it` blocks in TypeScript

## What to Test

- Pure utility functions (highest priority — no mocks needed)
- Filter/validation logic
- i18n key structure and completeness
- State management logic

## What NOT to Test

- Type definitions with no logic
- Simple re-exports

## Verification

```bash
bun run test    # Run full Vitest suite
bun run check   # TypeScript/Svelte type checking
```
