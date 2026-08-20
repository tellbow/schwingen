<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { escapeFilterValue } from '$lib/utils/filter';

	let { data } = $props();

	let filterResult = $state('');
	let filterPoints = $state('');
	let filterRound = $state('');
	let filterWrestlerName = $state('');
	let filterWrestlerVorname = $state('');
	let filterOpponentName = $state('');
	let filterOpponentVorname = $state('');
	let filterPlaceName = $state('');
	let filterYear = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const RESULTS = ['', 'o', '-', '+'];
	const POINTS = ['', '0.25', '8.25', '8.50', '8.75', '9.00', '9.25', '9.50', '9.75', '10.00', '10.25'];
	const ROUNDS = ['', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
	const YEARS = ['', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026'];

	function buildFilter(): string {
		const parts: string[] = [];
		if (filterResult) parts.push(`result = "${escapeFilterValue(filterResult)}"`);
		if (filterPoints) parts.push(`points = "${escapeFilterValue(filterPoints)}"`);
		if (filterRound) parts.push(`fight_round = "${escapeFilterValue(filterRound)}"`);
		if (filterWrestlerName) parts.push(`wrestler.name ~ "${escapeFilterValue(filterWrestlerName)}"`);
		if (filterWrestlerVorname)
			parts.push(`wrestler.vorname ~ "${escapeFilterValue(filterWrestlerVorname)}"`);
		if (filterOpponentName)
			parts.push(`opponent.name ~ "${escapeFilterValue(filterOpponentName)}"`);
		if (filterOpponentVorname)
			parts.push(`opponent.vorname ~ "${escapeFilterValue(filterOpponentVorname)}"`);
		if (filterPlaceName) parts.push(`place.name ~ "${escapeFilterValue(filterPlaceName)}"`);
		if (filterYear) parts.push(`place.year ~ "${escapeFilterValue(filterYear)}"`);
		return parts.join(' && ');
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			const filter = buildFilter();
			const params = new URLSearchParams();
			if (filter) params.set('filter', filter);
			await goto(`/bouts?${params.toString()}`, { invalidateAll: true, keepFocus: true });
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		const filter = buildFilter();
		const params = new URLSearchParams($page.url.searchParams);
		params.set('page', String(p));
		if (filter) params.set('filter', filter);
		goto(`/bouts?${params.toString()}`, { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>Paarungen - Tellbow</title>
	<meta name="description" content="Alle Paarungen und Ergebnisse von Schweizer Schwingern." />
</svelte:head>

<h1 class="sr-only">Paarungen - Tellbow</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full">
		<thead>
			<tr>
				<th>Res.</th>
				<th class="hidden md:table-cell">Punkte</th>
				<th class="hidden md:table-cell">Gang</th>
				<th>Name</th>
				<th class="hidden md:table-cell">Vorname</th>
				<th>Gegner</th>
				<th class="hidden md:table-cell">Geg. Vorname</th>
				<th>Schwingfest</th>
				<th class="hidden md:table-cell">Jahr</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1">
					<select class="filter-input" bind:value={filterResult} onchange={search}>
						{#each RESULTS as r}
							<option value={r}>{r || 'Alle'}</option>
						{/each}
					</select>
				</th>
				<th class="p-1 hidden md:table-cell">
					<select class="filter-input" bind:value={filterPoints} onchange={search}>
						{#each POINTS as p}
							<option value={p}>{p || 'Alle'}</option>
						{/each}
					</select>
				</th>
				<th class="p-1 hidden md:table-cell">
					<select class="filter-input" bind:value={filterRound} onchange={search}>
						{#each ROUNDS as r}
							<option value={r}>{r || 'Alle'}</option>
						{/each}
					</select>
				</th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Name" bind:value={filterWrestlerName} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<input type="text" class="filter-input" placeholder="Vorname" bind:value={filterWrestlerVorname} oninput={search} />
				</th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Gegner" bind:value={filterOpponentName} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<input type="text" class="filter-input" placeholder="Vorname" bind:value={filterOpponentVorname} oninput={search} />
				</th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Schwingfest" bind:value={filterPlaceName} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<select class="filter-input" bind:value={filterYear} onchange={search}>
						{#each YEARS as y}
							<option value={y}>{y || 'Alle'}</option>
						{/each}
					</select>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr><td colspan="9" class="text-center py-8"><div class="spinner mx-auto"></div></td></tr>
			{:else if data.bouts.length === 0}
				<tr><td colspan="9" class="text-center py-8 text-muted-foreground">Keine Paarungen gefunden.</td></tr>
			{:else}
				{#each data.bouts as b}
					<tr>
						<td class="font-mono">
							{b.result}
							<span class="block text-xs text-muted-foreground md:hidden">{b.points} · G{b.fight_round} · {b.year}</span>
						</td>
						<td class="hidden md:table-cell">{b.points}</td>
						<td class="hidden md:table-cell">{b.fight_round}</td>
						<td
							class="underline cursor-pointer"
							onclick={() => goto(`/wrestler/${b.expand?.wrestler?.id}`)}
						>
							{b.expand?.wrestler?.name ?? '-'}
							<span class="block text-xs text-muted-foreground md:hidden">{b.expand?.wrestler?.vorname ?? ''}</span>
						</td>
						<td class="hidden md:table-cell">{b.expand?.wrestler?.vorname ?? '-'}</td>
						<td
							class="underline cursor-pointer"
							onclick={() => goto(`/wrestler/${b.expand?.opponent?.id}`)}
						>
							{b.expand?.opponent?.name ?? '-'}
							<span class="block text-xs text-muted-foreground md:hidden">{b.expand?.opponent?.vorname ?? ''}</span>
						</td>
						<td class="hidden md:table-cell">{b.expand?.opponent?.vorname ?? '-'}</td>
						<td
							class="underline cursor-pointer"
							onclick={() => goto(`/rankings/${b.expand?.place?.id}`)}
						>
							{b.expand?.place?.name ?? '-'}
						</td>
						<td class="hidden md:table-cell">{b.year}</td>
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
