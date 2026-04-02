Generate a test file for: $ARGUMENTS

Steps:

1. Read the target file to understand its exports, functions, types, and dependencies.
2. Generate a `.test.ts` file alongside the source file.
3. Use `describe`/`it` blocks with Vitest:
   - Import `describe`, `it`, `expect`, `vi` from `"vitest"`
   - Use `vi.mock("module")` for module-level mocks
   - Use `vi.fn()` for function spies and stubs
   - Mock `localStorage` via `vi.spyOn(window.localStorage, "getItem")` etc.
   - Mock SvelteKit modules inline: `vi.mock("$app/environment", () => ({ browser: true }))`
4. Cover success paths, error paths, and edge cases for every exported function.
5. Follow project conventions: no comments in code, tabs for indentation.
6. Run the generated tests with `bun run test` to verify they pass (or fail meaningfully).
