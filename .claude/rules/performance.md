# Performance Patterns

## Svelte 5 Reactivity

- Use `$state` and `$derived` for fine-grained reactivity — avoid unnecessary re-renders
- Use `$derived` for computed values instead of recalculating in markup
- Avoid putting large arrays/objects in `$state` when only a subset is displayed

## Chart.js

Chart.js and related packages (`chartjs-chart-geo`, `chartjs-plugin-datalabels`) are heavy. Load them only where needed:

```typescript
// In +page.svelte for wrestler detail — lazy import
import { onMount } from "svelte";
onMount(async () => {
  const { Chart, registerables } = await import("chart.js");
  Chart.register(...registerables);
});
```

Do not import chart.js at the top level of shared utilities or layout files.

## PocketBase Query Optimization

- **Filter server-side**: always use `buildFilterString()` and pass filters in the query options — never fetch all records and filter client-side
- **Expand relations**: use the `expand` option to fetch related records in one request — never make N+1 separate requests
- **Paginate**: default page size is 15 items; never fetch unbounded lists
- **Select fields**: use the `fields` option to fetch only the columns you need for list views

```typescript
// Good: server-side filter + expand + pagination
pb.collection("rankings").getList(1, 15, {
  filter: buildFilterString({ wrestler: id }),
  expand: "wrestler,place",
  fields: "id,rank,points,expand.wrestler.name,expand.place.name"
});
```

## PWA Caching

The service worker caching strategy is already configured in `vite.config.ts`:
- NetworkFirst for `/api/collections/*` (always fresh data)
- CacheFirst for images (30-day max age)
- Static assets precached on install

Do not modify this configuration without understanding the impact on offline behavior.
