<script lang="ts">
	import { buildSearchParams } from '$lib/utils/search-params';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';
	import Pagination from '$lib/components/pagination.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

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
	const POINTS = [
		'',
		'0.25',
		'8.25',
		'8.50',
		'8.75',
		'9.00',
		'9.25',
		'9.50',
		'9.75',
		'10.00',
		'10.25'
	];
	const ROUNDS = ['', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
	const YEARS = [
		'',
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
				result: filterResult,
				points: filterPoints,
				round: filterRound,
				wrestlerName: filterWrestlerName,
				wrestlerVorname: filterWrestlerVorname,
				opponentName: filterOpponentName,
				opponentVorname: filterOpponentVorname,
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
			await goto(localizePath(`/bouts?${buildParams(1).toString()}`, locale), {
				invalidateAll: true,
				keepFocus: true
			});
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		goto(localizePath(`/bouts?${buildParams(p).toString()}`, locale), { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>{t(locale, 'bouts.metaTitle')}</title>
	<meta name="description" content={t(locale, 'bouts.metaDescription')} />
	<meta property="og:title" content={t(locale, 'bouts.metaTitle')} />
	<meta property="og:description" content={t(locale, 'bouts.metaDescription')} />
</svelte:head>

<h1 class="sr-only">{t(locale, 'bouts.metaTitle')}</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full">
		<thead>
			<tr>
				<th>{t(locale, 'bouts.colResult')}</th>
				<th class="hidden md:table-cell">{t(locale, 'bouts.points')}</th>
				<th class="hidden md:table-cell">{t(locale, 'bouts.round')}</th>
				<th>{t(locale, 'wrestler.name')}</th>
				<th class="hidden md:table-cell">{t(locale, 'wrestler.firstName')}</th>
				<th>{t(locale, 'bouts.opponent')}</th>
				<th class="hidden md:table-cell">{t(locale, 'bouts.opponentFirstName')}</th>
				<th>{t(locale, 'rankings.colSchwingfest')}</th>
				<th class="hidden md:table-cell">{t(locale, 'rankings.colYear')}</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1">
					<select class="filter-input" bind:value={filterResult} onchange={search}>
						{#each RESULTS as r (r)}
							<option value={r}>{r || t(locale, 'common.all')}</option>
						{/each}
					</select>
				</th>
				<th class="hidden p-1 md:table-cell">
					<select class="filter-input" bind:value={filterPoints} onchange={search}>
						{#each POINTS as p (p)}
							<option value={p}>{p || t(locale, 'common.all')}</option>
						{/each}
					</select>
				</th>
				<th class="hidden p-1 md:table-cell">
					<select class="filter-input" bind:value={filterRound} onchange={search}>
						{#each ROUNDS as r (r)}
							<option value={r}>{r || t(locale, 'common.all')}</option>
						{/each}
					</select>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.name')}
						bind:value={filterWrestlerName}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.firstName')}
						bind:value={filterWrestlerVorname}
						oninput={search}
					/>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'bouts.opponent')}
						bind:value={filterOpponentName}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.firstName')}
						bind:value={filterOpponentVorname}
						oninput={search}
					/>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'rankings.colSchwingfest')}
						bind:value={filterPlaceName}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<select class="filter-input" bind:value={filterYear} onchange={search}>
						{#each YEARS as y (y)}
							<option value={y}>{y || t(locale, 'common.all')}</option>
						{/each}
					</select>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr><td colspan="9" class="py-8 text-center"><div class="spinner mx-auto"></div></td></tr>
			{:else if data.bouts.length === 0}
				<tr
					><td colspan="9" class="py-8 text-center text-muted-foreground"
						>{t(locale, 'bouts.noResultsFound')}</td
					></tr
				>
			{:else}
				{#each data.bouts as b (b.id)}
					<tr>
						<td class="font-mono">
							{b.result}
							<span class="block text-xs text-muted-foreground md:hidden"
								>{b.points} · G{b.fight_round} · {b.year}</span
							>
						</td>
						<td class="hidden md:table-cell">{b.points}</td>
						<td class="hidden md:table-cell">{b.fight_round}</td>
						<td>
							<a href="/wrestler/{b.expand?.wrestler?.id}" class="underline">
								{b.expand?.wrestler?.name ?? '-'}
							</a>
							<span class="block text-xs text-muted-foreground md:hidden"
								>{b.expand?.wrestler?.vorname ?? ''}</span
							>
						</td>
						<td class="hidden md:table-cell">{b.expand?.wrestler?.vorname ?? '-'}</td>
						<td>
							<a href="/wrestler/{b.expand?.opponent?.id}" class="underline">
								{b.expand?.opponent?.name ?? '-'}
							</a>
							<span class="block text-xs text-muted-foreground md:hidden"
								>{b.expand?.opponent?.vorname ?? ''}</span
							>
						</td>
						<td class="hidden md:table-cell">{b.expand?.opponent?.vorname ?? '-'}</td>
						<td>
							<a href="/rankings/{b.expand?.place?.id}" class="underline">
								{b.expand?.place?.name ?? '-'}
							</a>
						</td>
						<td class="hidden md:table-cell">{b.year}</td>
					</tr>
				{/each}
			{/if}
		</tbody>
	</table>
</div>

<Pagination page={data.page} {totalPages} onNavigate={goToPage} {locale} />
