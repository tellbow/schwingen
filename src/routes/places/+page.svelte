<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { formatDate } from '$lib/utils/format';

	let { data } = $props();

	let filterNumber = $state('');
	let filterName = $state('');
	let filterLocation = $state('');
	let filterYear = $state('');
	let filterType = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const YEARS = ['', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025'];
	const PLACE_TYPES = [
		'',
		'Sonstige',
		'Gauverband',
		'Regional',
		'mit eidgenössischem Charakter',
		'Eidgenössisch',
		'Teilverband',
		'Kantonal',
		'Berg'
	];

	function buildFilter(): string {
		const parts: string[] = [];
		if (filterNumber) parts.push(`number ~ "${escapeFilterValue(filterNumber)}"`);
		if (filterName) parts.push(`name ~ "${escapeFilterValue(filterName)}"`);
		if (filterLocation) parts.push(`location ~ "${escapeFilterValue(filterLocation)}"`);
		if (filterYear) parts.push(`year ~ "${escapeFilterValue(filterYear)}"`);
		if (filterType) parts.push(`placeType.type = "${escapeFilterValue(filterType)}"`);
		return parts.join(' && ');
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			const filter = buildFilter();
			const params = new URLSearchParams();
			if (filter) params.set('filter', filter);
			await goto(`/places?${params.toString()}`, { invalidateAll: true });
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		const filter = buildFilter();
		const params = new URLSearchParams($page.url.searchParams);
		params.set('page', String(p));
		if (filter) params.set('filter', filter);
		goto(`/places?${params.toString()}`, { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>Schwingfeste - Tellbow</title>
	<meta name="description" content="Alle Schwingfeste der Aktiven aus den Jahren 2015-2025." />
</svelte:head>

<h1 class="sr-only">Schwingfeste - Tellbow</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full">
		<thead>
			<tr>
				<th class="hidden md:table-cell">Nr.</th>
				<th>Name</th>
				<th class="hidden md:table-cell">Ort</th>
				<th>Datum</th>
				<th class="hidden md:table-cell">Typ</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1 hidden md:table-cell">
					<input type="text" class="filter-input" placeholder="Nr." bind:value={filterNumber} oninput={search} />
				</th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Name" bind:value={filterName} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<input type="text" class="filter-input" placeholder="Ort" bind:value={filterLocation} oninput={search} />
				</th>
				<th class="p-1">
					<select class="filter-input" bind:value={filterYear} onchange={search}>
						{#each YEARS as y}
							<option value={y}>{y || 'Alle'}</option>
						{/each}
					</select>
				</th>
				<th class="p-1 hidden md:table-cell">
					<select class="filter-input" bind:value={filterType} onchange={search}>
						{#each PLACE_TYPES as t}
							<option value={t}>{t || 'Alle'}</option>
						{/each}
					</select>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr><td colspan="5" class="text-center py-8"><div class="spinner mx-auto"></div></td></tr>
			{:else if data.places.length === 0}
				<tr><td colspan="5" class="text-center py-8 text-muted-foreground">Keine Schwingfeste gefunden.</td></tr>
			{:else}
				{#each data.places as p}
					<tr class="cursor-pointer" onclick={() => goto(`/rankings/${p.id}`)}>
						<td class="hidden md:table-cell">{p.number}</td>
						<td class="font-medium">
							<a href="/rankings/{p.id}" class="hover:underline">
								{p.name}
							</a>
							<span class="block text-xs text-muted-foreground md:hidden">{p.expand?.placeType?.type ?? ''}</span>
						</td>
						<td class="hidden md:table-cell">{p.location ?? '-'}</td>
						<td class="whitespace-nowrap">{formatDate(p.year)}</td>
						<td class="hidden md:table-cell text-xs">{p.expand?.placeType?.type ?? '-'}</td>
					</tr>
				{/each}
			{/if}
		</tbody>
	</table>
</div>

{#if totalPages > 1}
	<div class="flex flex-col items-center gap-1 mt-4 py-3">
		<div class="flex gap-1">
			<button class="pagination-btn" disabled={data.page <= 1} onclick={() => goToPage(data.page - 1)}>‹</button>
			{#each Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
				const half = 2;
				let start = Math.max(1, data.page - half);
				const end = Math.min(totalPages, start + 4);
				start = Math.max(1, end - 4);
				return start + i;
			}) as p}
				<button class="pagination-btn {p === data.page ? 'pagination-active' : ''}" onclick={() => goToPage(p)}>{p}</button>
			{/each}
			<button class="pagination-btn" disabled={data.page >= totalPages} onclick={() => goToPage(data.page + 1)}>›</button>
		</div>
		<span class="text-sm text-muted-foreground">Seite {data.page} von {totalPages}</span>
	</div>
{/if}
