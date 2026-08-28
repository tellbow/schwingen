# Tellbow Design Styleguide

**Theme name:** Alpine Ledger — The Earth & Iron Framework

---

## Color Tokens

All colors must come from CSS custom properties defined in `app.css`. Never use hardcoded Tailwind color classes (`text-gray-*`, `bg-white`, `text-red-*`, etc.).

### Surface hierarchy (light → dark tonal elevation)

| Token | Class | Use |
|-------|-------|-----|
| `--color-background` | `bg-background` | Page background |
| `--color-surface` | `bg-surface` | Same as background |
| `--color-surface-lowest` | `bg-surface-lowest` | Elevated cards, card backgrounds |
| `--color-surface-low` | `bg-surface-low` | Slightly elevated (nav, sidebar) |
| `--color-surface-container` | `bg-surface-container` | Input backgrounds, filter areas |
| `--color-surface-high` | `bg-surface-high` | Active nav items |
| `--color-surface-highest` | `bg-surface-highest` | Highest elevation |
| `--color-surface-dim` | `bg-surface-dim` | Dimmed/disabled surfaces |

### Text

| Token | Class | Use |
|-------|-------|-----|
| `--color-foreground` | `text-foreground` | Primary text |
| `--color-muted-foreground` | `text-muted-foreground` | Secondary/supporting text |
| `--color-outline` | `text-outline` | Tertiary text, icons |
| `--color-primary` | `text-primary` | Brand/accent text |

### Interactive

| Token | Class | Use |
|-------|-------|-----|
| `--color-primary` | `bg-primary` | Primary action fill |
| `--color-primary-foreground` | `text-primary-foreground` | Text on primary fill |
| `--color-primary-container` | `bg-primary-container` | Subtle accent fill |
| `--color-on-primary-container` | `text-on-primary-container` | Text on primary-container |

### Borders

| Token | Class | Use |
|-------|-------|-----|
| `--color-border` | `border-border` | Standard dividers |
| `--color-outline-variant` | `border-outline-variant` | Subtle dividers |

### Semantic

| Token | Class | Use |
|-------|-------|-----|
| `--color-tertiary-fixed` | `bg-tertiary-fixed` | Win chip background |
| `--color-on-tertiary-fixed-variant` | `text-on-tertiary-fixed-variant` | Win chip text |
| `--color-tertiary-container` | `bg-tertiary-container` | Win chip (dark) |
| `--color-error` | `text-error` | Error/destructive text |
| `--color-error-container` | `bg-error-container` | Loss chip background |
| `--color-on-error-container` | `text-on-error-container` | Loss chip text |
| `--color-secondary` | `bg-secondary` | Draw chip background |
| `--color-secondary-foreground` | `text-secondary-foreground` | Draw chip text |

---

## Typography

Body font: `Inter`, system-ui, sans-serif. Headings use `letter-spacing: -0.02em`.

Display serif (`font-serif`, token `--font-serif`): `Bitter`, Georgia, serif — used for the homepage hero headline and other large editorial headings (see `Hero.svelte`, `DestinationGrid.svelte`, `StatStrip.svelte`). Never use it for UI chrome (nav, buttons, tables, forms) — those stay on the body font or `font-sans` (token `--font-sans`, the plain system UI stack — see the nav logo in `Header.svelte`).

| Usage | Classes |
|-------|---------|
| Page title (h1) | `text-2xl font-bold tracking-tight text-foreground` |
| Section header (h2) | `text-lg font-semibold text-foreground` |
| Card title | Use `.card-title` class |
| Table headers | `text-xs font-semibold uppercase tracking-tight text-foreground` |
| Table cells | `text-sm text-foreground` |
| Supporting/secondary text | `text-sm text-muted-foreground` |
| Metadata/labels | `text-xs text-outline` |

---

## Spacing

Base grid: 4px. Use Tailwind spacing utilities.

| Context | Classes |
|---------|---------|
| Page padding | `px-3 md:px-6 py-6` |
| Card padding | `p-5` (via `.card`) |
| Section gap | `space-y-6` or `gap-6` |
| Row gap | `gap-3` or `gap-4` |
| Inline gap | `gap-2` |

---

## Border Radius

| Token | Class | Use |
|-------|-------|-----|
| `--radius-sm` (0.25rem) | `rounded-[--radius-sm]` or `rounded` | Small elements |
| `--radius-md` (0.375rem) | `rounded-[--radius-md]` or `rounded-md` | Inputs, badges |
| `--radius-lg` (0.5rem) | `rounded-[--radius-lg]` or `rounded-lg` | Buttons, nav items |
| `--radius-xl` (0.75rem) | `rounded-[--radius-xl]` or `rounded-xl` | Cards |

---

## Components

### Cards

Use the `.card` utility class. No drop shadows — tonal depth only.

```html
<div class="card">
  <h2 class="card-title">Title</h2>
  ...
</div>
```

For cards with border: `bg-card border border-border rounded-xl p-5`.

**Never:** `shadow-md`, `shadow-lg`, `bg-white`, or hardcoded colors.

### Buttons

Always use `.btn-primary` or the shadcn `Button` component.

```html
<!-- Primary action -->
<a href="..." class="btn-primary inline-block">Label</a>
<Button variant="default">Label</Button>

<!-- Secondary -->
<Button variant="secondary">Label</Button>
<Button variant="outline">Label</Button>
<Button variant="ghost">Label</Button>
```

**Never:** Raw `<button>` with inline Tailwind colors.

### Tables

Use the `.data-table` class on `<table>` elements.

```html
<table class="data-table">
  <thead><tr><th>Column</th></tr></thead>
  <tbody><tr><td>Value</td></tr></tbody>
</table>
```

### Inputs / Filters

Use `.filter-input` for text search inputs or `.select-input` for dropdowns.

```html
<input class="filter-input" type="text" />
<select class="select-input">...</select>
```

### Result Chips (bout outcomes)

```html
<span class="chip-win">Sieg</span>
<span class="chip-draw">Gestellter</span>
<span class="chip-loss">Niederlage</span>
```

### Pagination

```html
<div class="pagination">
  <button class="pagination-btn">Zurück</button>
  <button class="pagination-btn pagination-active">1</button>
  <button class="pagination-btn">Weiter</button>
</div>
```

### Icons

Always use `lucide-svelte`. Sizes by context:

| Context | Size |
|---------|------|
| Navigation | `size={16}` |
| Actions / inline | `size={18}` |
| Standalone / large | `size={20}` |

---

## Motion

- Hover transitions: `transition-colors` (150ms default)
- No page transitions or decorative animations
- Mobile nav: `slide` transition with `duration: 150`

---

## Dark Mode

Dark mode is toggled via the `.dark` class on `<html>`. All color tokens automatically switch — no manual dark: variants needed for colors already covered by the token system.

Use `dark:` prefix only for structural adjustments not covered by tokens (e.g., `dark:bg-surface-high` for a specific override).

---

## Dropdown / Autocomplete

Dropdowns (e.g., autocomplete search results) use:

```html
<ul class="absolute z-10 w-full bg-surface-lowest border border-border rounded-lg overflow-hidden">
  <li class="px-3 py-2 text-sm hover:bg-surface-container cursor-pointer">...</li>
</ul>
```

**Never:** `bg-white`, `border-gray-*`, `shadow-lg` on dropdowns.
