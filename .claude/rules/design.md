# Design Styleguide

Always follow the design styleguide at `docs/design/styleguide.md` when writing or modifying any UI code.

Read it before implementing new components, pages, or visual changes. Key rules:

- **Colors**: use CSS custom property tokens only (`--background`, `--foreground`, `--card`, `--muted`, `--border`, `--primary`, etc.) — never hardcoded hex values or Tailwind color classes like `text-gray-500`
- **Typography**: follow the defined type scale and font weights — `text-sm` for table cells, `text-lg` for section headers, `font-medium` for labels
- **Spacing**: 4px base grid — use Tailwind spacing utilities (`p-4`, `p-6`, `gap-3`, `space-y-6`)
- **Border radius**: use radius tokens (`rounded-[--radius]`, `rounded-[--radius-sm]`, `rounded-[--radius-lg]`)
- **Buttons**: always use the shadcn-svelte `Button` component with the correct variant (`default`, `secondary`, `outline`, `ghost`, `destructive`)
- **Icons**: always use `lucide-svelte`, sized by context (nav: `h-4 w-4`, actions: `h-5 w-5`)
- **Motion**: hover transitions 150ms only — no page transitions or decorative animations
- **Cards**: border-only, no drop shadows — `bg-card border border-border rounded-[--radius]`

When in doubt about a design decision, check the styleguide first.
