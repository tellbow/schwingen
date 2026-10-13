Run the full verification pipeline for Tellbow.

Execute all steps, continuing past failures to report the complete picture:

1. `bun run lint` — Prettier + ESLint
2. `bun run check` — Svelte/TypeScript type checking
3. `bun run test` — Vitest unit tests
4. `bun run build` — Production build

Report each step as PASS or FAIL with error output for failures.
Provide a summary line at the end: "X/4 passed" or "All 4 checks passed".
