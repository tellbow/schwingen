<script lang="ts">
	import type { BoutRecord, RankingRecord } from '$lib/types/pocketbase';
	import { buildSearchParams } from '$lib/utils/search-params';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { getClientPb } from '$lib/pb';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';
	import Pagination from '$lib/components/pagination.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

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
	let expandedBouts = $state<Record<string, BoutRecord[]>>({});
	let loadingBouts = $state<Record<string, boolean>>({});

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const YEARS = [
		'2015',
		'2016',
		'2017',
		'2018',
		'2019',
		'2020',
		'2021',
		'2022',
		'2023',
		'2024',
		'2025',
		'2026'
	];

	function buildParams(pageNum: number): URLSearchParams {
		return buildSearchParams(
			{
				rank: filterRank,
				points: filterPoints,
				final: filterFinal,
				wreath: filterWreath,
				wrestlerName: filterWrestlerName,
				wrestlerVorname: filterWrestlerVorname,
				placeName: filterPlaceName,
				year: filterYear
			},
			pageNum
		);
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			await goto(localizePath(`/rankings?${buildParams(1).toString()}`, locale), {
				invalidateAll: true,
				keepFocus: true
			});
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		goto(localizePath(`/rankings?${buildParams(p).toString()}`, locale), { invalidateAll: true });
	}

	async function toggleExpand(row: RankingRecord) {
		const key = row.id;
		if (expandedBouts[key] !== undefined) {
			const rest = { ...expandedBouts };
			delete rest[key];
			expandedBouts = rest;
			return;
		}
		loadingBouts = { ...loadingBouts, [key]: true };
		const pb = getClientPb();
		try {
			const d = await pb.collection('bouts').getList<BoutRecord>(1, 10, {
				filter: `wrestler.id = '${escapeFilterValue(row.expand?.wrestler?.id ?? '')}' && place.id = '${escapeFilterValue(row.expand?.place?.id ?? '')}'`,
				expand: 'opponent',
				sort: 'fight_round,-created',
				fields:
					'id,result,points,fight_round,expand.opponent.id,expand.opponent.name,expand.opponent.vorname'
			});
			expandedBouts = { ...expandedBouts, [key]: d.items };
		} catch (e) {
			console.error(e);
			expandedBouts = { ...expandedBouts, [key]: [] };
		} finally {
			const rest = { ...loadingBouts };
			delete rest[key];
			loadingBouts = rest;
		}
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>{t(locale, 'rankings.metaTitle')}</title>
	<meta name="description" content={t(locale, 'rankings.metaDescription')} />
	<meta property="og:title" content={t(locale, 'rankings.metaTitle')} />
	<meta property="og:description" content={t(locale, 'rankings.metaDescription')} />
</svelte:head>

<h1 class="sr-only">{t(locale, 'rankings.metaTitle')}</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full">
		<thead>
			<tr>
				<th class="w-8"></th>
				<th>{t(locale, 'rankings.rank')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.points')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.colFinal')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.result')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.wreath')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.colStatus')}</th>
				<th>{t(locale, 'wrestler.name')}</th>
				<th class="hidden md:table-cell">{t(locale, 'wrestler.firstName')}</th>
				<th>{t(locale, 'rankings.colSchwingfest')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.colYear')}</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1"></th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'rankings.filterRank')}
						bind:value={filterRank}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'rankings.filterPoints')}
						bind:value={filterPoints}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input type="checkbox" bind:checked={filterFinal} onchange={search} />
				</th>
				<th class="hidden p-1 md:table-cell"></th>
				<th class="hidden p-1 md:table-cell">
					<input type="checkbox" bind:checked={filterWreath} onchange={search} />
				</th>
				<th class="hidden p-1 md:table-cell"></th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'rankings.filterWrestlerName')}
						bind:value={filterWrestlerName}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'rankings.filterWrestlerVorname')}
						bind:value={filterWrestlerVorname}
						oninput={search}
					/>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'rankings.filterPlaceName')}
						bind:value={filterPlaceName}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<select class="filter-input" bind:value={filterYear} onchange={search}>
						<option value="">{t(locale, 'common.all')}</option>
						{#each YEARS as y (y)}
							<option value={y}>{y}</option>
						{/each}
					</select>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr><td colspan="11" class="py-8 text-center"><div class="spinner mx-auto"></div></td></tr>
			{:else if data.rankings.length === 0}
				<tr
					><td colspan="11" class="py-8 text-center text-muted-foreground"
						>{t(locale, 'rankings.noResultsFound')}</td
					></tr
				>
			{:else}
				{#each data.rankings as r (r.id)}
					<tr class="cursor-pointer" onclick={() => toggleExpand(r)}>
						<td class="text-center text-outline">
							{expandedBouts[r.id] !== undefined
								? t(locale, 'rankings.toggleHide')
								: t(locale, 'rankings.toggleShow')}
						</td>
						<td>
							{r.rank}{r.rank2}
							<span class="block text-xs text-muted-foreground md:hidden">{r.points}</span>
						</td>
						<td class="hidden md:table-cell">{r.points}</td>
						<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
						<td class="hidden font-mono text-xs md:table-cell">{r.result}</td>
						<td class="hidden md:table-cell">{r.wreath ? '🏆' : ''}</td>
						<td class="hidden text-xs md:table-cell">{r.status ?? ''}</td>
						<td>
							<a
								href="/wrestler/{r.expand?.wrestler?.id}"
								class="underline"
								onclick={(e) => e.stopPropagation()}
							>
								{r.expand?.wrestler?.name ?? '-'}
							</a>
							<span class="block text-xs text-muted-foreground md:hidden"
								>{r.expand?.wrestler?.vorname ?? ''}</span
							>
						</td>
						<td class="hidden md:table-cell">{r.expand?.wrestler?.vorname ?? '-'}</td>
						<td>
							<a
								href="/rankings/{r.expand?.place?.id}"
								class="underline"
								onclick={(e) => e.stopPropagation()}
							>
								{r.expand?.place?.name ?? '-'}
							</a>
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
							<td colspan="11" class="bg-surface-low p-2">
								{#if expandedBouts[r.id].length === 0}
									<p class="text-sm text-muted-foreground">{t(locale, 'rankings.noBouts')}</p>
								{:else}
									<table class="w-full border border-border text-xs">
										<thead>
											<tr class="bg-surface-container">
												<th class="px-2 py-1 text-left">{t(locale, 'rankings.gang')}</th>
												<th class="px-2 py-1 text-left">{t(locale, 'rankings.result')}</th>
												<th class="px-2 py-1 text-left">{t(locale, 'rankings.points')}</th>
												<th class="px-2 py-1 text-left">{t(locale, 'rankings.opponent')}</th>
											</tr>
										</thead>
										<tbody>
											{#each expandedBouts[r.id] as b (b.id)}
												<tr class="border-t border-outline-variant/20">
													<td class="px-2 py-1">{b.fight_round}</td>
													<td class="px-2 py-1 font-mono">{b.result}</td>
													<td class="px-2 py-1">{b.points}</td>
													<td class="px-2 py-1">
														<a href="/wrestler/{b.expand?.opponent?.id}" class="underline">
															{b.expand?.opponent?.name}
															{b.expand?.opponent?.vorname}
														</a>
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

<Pagination page={data.page} {totalPages} onNavigate={goToPage} {locale} />
