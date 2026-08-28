<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { getClientPb } from '$lib/pb';

	let { data } = $props();

	let filterRank = $state('');
	let filterPoints = $state('');
	let filterFinal = $state(false);
	let filterWreath = $state(false);
	let filterWrestlerName = $state('');
	let filterWrestlerVorname = $state('');
	let filterPlaceName = $state('');
	let filterYear = $state('');
	let loading = $state(false);

	// Expanded rows: map of id -> bouts[]
	let expandedBouts = $state<Record<string, any[]>>({});
	let loadingBouts = $state<Record<string, boolean>>({});

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const YEARS = ['2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026'];

	function buildFilter(): string {
		const parts: string[] = [];
		if (filterRank) parts.push(`rank = "${escapeFilterValue(filterRank)}"`);
		if (filterPoints) parts.push(`points = "${escapeFilterValue(filterPoints)}"`);
		if (filterFinal) parts.push('final = true');
		if (filterWreath) parts.push('wreath = true');
		if (filterWrestlerName)
			parts.push(`wrestler.name ~ "${escapeFilterValue(filterWrestlerName)}"`);
		if (filterWrestlerVorname)
			parts.push(`wrestler.vorname ~ "${escapeFilterValue(filterWrestlerVorname)}"`);
		if (filterPlaceName) parts.push(`place.name ~ "${escapeFilterValue(filterPlaceName)}"`);
		if (filterYear)
			parts.push(`place.year >= "2015" && place.year ~ "${escapeFilterValue(filterYear)}"`);
		return parts.join(' && ');
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			const filter = buildFilter();
			const params = new URLSearchParams();
			if (filter) params.set('filter', filter);
			await goto(`/rankings?${params.toString()}`, { invalidateAll: true, keepFocus: true });
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		const filter = buildFilter();
		const params = new URLSearchParams($page.url.searchParams);
		params.set('page', String(p));
		if (filter) params.set('filter', filter);
		goto(`/rankings?${params.toString()}`, { invalidateAll: true });
	}

	async function toggleExpand(row: any) {
		const key = row.id;
		if (expandedBouts[key] !== undefined) {
			const { [key]: _, ...rest } = expandedBouts;
			expandedBouts = rest;
			return;
		}
		loadingBouts = { ...loadingBouts, [key]: true };
		const pb = getClientPb();
		try {
			const d = await pb.collection('bouts').getList(1, 10, {
				filter: `wrestler.id = '${escapeFilterValue(row.expand.wrestler.id)}' && place.id = '${escapeFilterValue(row.expand.place.id)}'`,
				expand: 'opponent',
				sort: 'fight_round,-created',
				fields: 'id,result,points,fight_round,expand.opponent.id,expand.opponent.name,expand.opponent.vorname'
			});
			expandedBouts = { ...expandedBouts, [key]: d.items };
		} catch (e) {
			console.error(e);
			expandedBouts = { ...expandedBouts, [key]: [] };
		} finally {
			const { [key]: _, ...rest } = loadingBouts;
			loadingBouts = rest;
		}
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>Ranglisten - Tellbow</title>
	<meta name="description" content="Alle Ranglisten und Ergebnisse von Schweizer Schwingern." />
	<meta property="og:title" content="Ranglisten - Tellbow" />
	<meta property="og:description" content="Alle Ranglisten und Ergebnisse von Schweizer Schwingern." />
</svelte:head>

<h1 class="sr-only">Ranglisten - Tellbow</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full">
		<thead>
			<tr>
				<th class="w-8"></th>
				<th>Rang</th>
				<th class="hidden md:table-cell">Punkte</th>
				<th class="hidden md:table-cell">SF</th>
				<th class="hidden md:table-cell">Resultat</th>
				<th class="hidden md:table-cell">Kranz</th>
				<th class="hidden md:table-cell">Status</th>
				<th>Name</th>
				<th class="hidden md:table-cell">Vorname</th>
				<th>Schwingfest</th>
				<th class="hidden md:table-cell">Jahr</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1"></th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Rang" bind:value={filterRank} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<input type="text" class="filter-input" placeholder="Punkte" bind:value={filterPoints} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<input type="checkbox" bind:checked={filterFinal} onchange={search} />
				</th>
				<th class="p-1 hidden md:table-cell"></th>
				<th class="p-1 hidden md:table-cell">
					<input type="checkbox" bind:checked={filterWreath} onchange={search} />
				</th>
				<th class="p-1 hidden md:table-cell"></th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Name" bind:value={filterWrestlerName} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<input type="text" class="filter-input" placeholder="Vorname" bind:value={filterWrestlerVorname} oninput={search} />
				</th>
				<th class="p-1">
					<input type="text" class="filter-input" placeholder="Schwingfest" bind:value={filterPlaceName} oninput={search} />
				</th>
				<th class="p-1 hidden md:table-cell">
					<select class="filter-input" bind:value={filterYear} onchange={search}>
						<option value="">Alle</option>
						{#each YEARS as y}
							<option value={y}>{y}</option>
						{/each}
					</select>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr><td colspan="11" class="text-center py-8"><div class="spinner mx-auto"></div></td></tr>
			{:else if data.rankings.length === 0}
				<tr><td colspan="11" class="text-center py-8 text-muted-foreground">Keine Ranglisten gefunden.</td></tr>
			{:else}
				{#each data.rankings as r}
					<tr class="cursor-pointer" onclick={() => toggleExpand(r)}>
						<td class="text-center text-outline">
							{expandedBouts[r.id] !== undefined ? '▲' : '▼'}
						</td>
						<td>
							{r.rank}{r.rank2}
							<span class="block text-xs text-muted-foreground md:hidden">{r.points}</span>
						</td>
						<td class="hidden md:table-cell">{r.points}</td>
						<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
						<td class="hidden md:table-cell font-mono text-xs">{r.result}</td>
						<td class="hidden md:table-cell">{r.wreath ? '🏆' : ''}</td>
						<td class="hidden md:table-cell text-xs">{r.status ?? ''}</td>
						<td
							class="underline cursor-pointer"
							onclick={(e) => { e.stopPropagation(); goto(`/wrestler/${r.expand?.wrestler?.id}`); }}
						>
							{r.expand?.wrestler?.name ?? '-'}
							<span class="block text-xs text-muted-foreground md:hidden">{r.expand?.wrestler?.vorname ?? ''}</span>
						</td>
						<td class="hidden md:table-cell">{r.expand?.wrestler?.vorname ?? '-'}</td>
						<td
							class="underline cursor-pointer"
							onclick={(e) => { e.stopPropagation(); goto(`/rankings/${r.expand?.place?.id}`); }}
						>
							{r.expand?.place?.name ?? '-'}
							<span class="block text-xs text-muted-foreground md:hidden">{r.year}</span>
						</td>
						<td class="hidden md:table-cell">{r.year}</td>
					</tr>
					{#if loadingBouts[r.id]}
						<tr>
							<td colspan="11" class="py-2 text-center text-sm">
								<div class="spinner mx-auto"></div>
							</td>
						</tr>
					{:else if expandedBouts[r.id] !== undefined}
						<tr>
							<td colspan="11" class="p-2 bg-surface-low">
								{#if expandedBouts[r.id].length === 0}
									<p class="text-sm text-muted-foreground">Keine Paarungen.</p>
								{:else}
									<table class="w-full text-xs border border-border">
										<thead>
											<tr class="bg-surface-container">
												<th class="px-2 py-1 text-left">Gang</th>
												<th class="px-2 py-1 text-left">Resultat</th>
												<th class="px-2 py-1 text-left">Punkte</th>
												<th class="px-2 py-1 text-left">Gegner</th>
											</tr>
										</thead>
										<tbody>
											{#each expandedBouts[r.id] as b}
												<tr class="border-t border-outline-variant/20">
													<td class="px-2 py-1">{b.fight_round}</td>
													<td class="px-2 py-1 font-mono">{b.result}</td>
													<td class="px-2 py-1">{b.points}</td>
													<td class="px-2 py-1">
														<button
															class="underline cursor-pointer text-left"
															onclick={() => goto(`/wrestler/${b.expand?.opponent?.id}`)}
														>
															{b.expand?.opponent?.name} {b.expand?.opponent?.vorname}
														</button>
													</td>
												</tr>
											{/each}
										</tbody>
									</table>
								{/if}
							</td>
						</tr>
					{/if}
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
