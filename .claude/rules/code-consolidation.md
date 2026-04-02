# Code Consolidation

## Before Writing New Code

1. **Search first**: Before implementing any logic, search for existing implementations using grep or file search.
2. **Check shared utilities**: Consult `$lib/utils/` for existing implementations.
3. **Check the file map**: See `rewrite-conventions.md` for the authoritative list of what lives where.

## Anti-Duplication Rules

### Utilities

- **PocketBase filtering**: Always use `buildFilterString()` from `$lib/utils/filter.ts`. Never build PocketBase filter strings manually.
- **Input sanitization**: Always use `escapeFilterValue()` from `$lib/utils/filter.ts`. Never strip special characters inline.
- **Route param validation**: Always use `validateRouteParam()` from `$lib/utils/filter.ts`. Never write inline regex validation for route params.
- **Class merging**: Always use `cn()` from `$lib/utils.ts`. Never concatenate Tailwind classes manually.

### i18n

- **All UI strings**: Always use `t("section.key")` from `$lib/i18n/index.svelte.ts`. Never hardcode German or French strings in components.
- **Both locales together**: When adding a translation key, always add it to both `de` and `fr` in `translations.ts` at the same time.

### PocketBase

- **Client access**: Always `import pb from "$lib/pb"` (or `createServerPb()` / `getClientPb()`). Never instantiate `PocketBase` directly in components or routes.
- **Relation fetching**: Always use `expand` in the query options. Never make separate requests to fetch related records.

### Components

- **UI primitives**: Always use shadcn-svelte components (`Button`, `Input`, `Badge`) from `$lib/components/ui/`. Never write raw HTML with Tailwind utilities for these patterns.
- **Design tokens**: Always use CSS custom properties (`text-foreground`, `bg-card`, `border-border`, etc.). Never use hardcoded Tailwind colors (`text-gray-500`, `bg-white`, etc.).
- **Icons**: Always import from `lucide-svelte`. Never use inline SVGs or other icon libraries.

## When You Create a New Shared Utility

1. Add it to the file map in `rewrite-conventions.md`
2. Add an anti-duplication rule in this file
3. Search the codebase for existing duplicates and refactor them to use the new utility

## Code Smell Checklist

Before completing any change, verify:

- [ ] No function or pattern appears in more than one file (unless trivially small)
- [ ] No type or interface is defined in more than one file
- [ ] No hardcoded UI strings — all text goes through `t()`
- [ ] No hardcoded colors or magic numbers
- [ ] New code uses existing utilities rather than reimplementing them
- [ ] File sizes remain within limits
