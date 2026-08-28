<script lang="ts">
	import { page } from '$app/stores';
	import { getClientPb } from '$lib/pb';
	import { yearOnly } from '$lib/utils/format';
	import { t, type Locale } from '$lib/i18n/index.svelte';
	import WrestlerStatsCharts from '$lib/components/wrestler/wrestler-stats-charts.svelte';
	import WrestlerHeadToHead from '$lib/components/wrestler/wrestler-head-to-head.svelte';
	import WrestlerTopOpponents from '$lib/components/wrestler/wrestler-top-opponents.svelte';

	let { data } = $props();
	const wrestler = $derived(data.wrestler);
	const locale = $derived($page.data.locale as Locale);

	let selectedYear = $state<string | number>('Alle');
	let rankingsData = $state<any[]>([]);
	let opponentsData = $state<any[]>([]);
	let eloData = $state<any>(null);
	let wreath1 = $state(0);
	let wreath2 = $state(0);
	let wreath3 = $state(0);

	let loadingRankings = $state(true);
	let loadingOpponents = $state(true);

	const YEARS = [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 'Alle'];

	async function fetchEloForYear(pb: ReturnType<typeof getClientPb>, year: number) {
		try {
			const res = await pb.collection(`elo${year}`).getList(1, 1, {
				filter: `wrestler.id="${wrestler.id}"`,
				skipTotal: true,
				fields: 'id,rating'
			});
			return res.items[0] ?? null;
		} catch {
			return null;
		}
	}

	async function loadElo() {
		const pb = getClientPb();
		if (selectedYear === 'Alle') {
			const years = YEARS.filter((y) => y !== 'Alle')
				.map(Number)
				.sort((a, b) => b - a);
			const [mostRecent, ...rest] = years;
			const recentHit = await fetchEloForYear(pb, mostRecent);
			if (recentHit) {
				eloData = recentHit;
				return;
			}
			const results = await Promise.all(rest.map((y) => fetchEloForYear(pb, y)));
			eloData = results.find(Boolean) ?? { rating: '-' };
		} else {
			eloData = (await fetchEloForYear(pb, selectedYear as number)) ?? { rating: '-' };
		}
	}

	async function loadRankings() {
		loadingRankings = true;
		const pb = getClientPb();
		const filter =
			selectedYear === 'Alle'
				? `wrestler.id = "${wrestler.id}"`
				: `wrestler.id = "${wrestler.id}" && place.year ~ "${selectedYear}"`;

		try {
			const d = await pb.collection('rankings').getFullList(200, {
				filter,
				expand: 'place,place.placeType',
				sort: '-place.year,-created',
				fields:
					'id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.place.name,expand.place.year,expand.place.expand.placeType.type'
			});

			wreath1 = 0;
			wreath2 = 0;
			wreath3 = 0;
			d.forEach((item: any) => {
				if (item.wreath) {
					const t = item.expand?.place?.expand?.placeType?.type;
					if (t === 'Gauverband' || t === 'Kantonal') wreath1++;
					else if (t === 'Teilverband' || t === 'Berg') wreath2++;
					else if (t === 'Eidgenössisch') wreath3++;
				}
				if (item.expand?.place) {
					item.expand.place.originalDate = item.expand.place.year;
					item.expand.place.year = yearOnly(item.expand.place.year);
				}
			});
			rankingsData = d;
		} catch (e) {
			console.error(e);
			rankingsData = [];
		} finally {
			loadingRankings = false;
		}
	}

	async function loadOpponents() {
		loadingOpponents = true;
		const pb = getClientPb();
		const filter =
			selectedYear === 'Alle'
				? `wrestler.id = "${wrestler.id}"`
				: `wrestler.id = "${wrestler.id}" && place.year ~ "${selectedYear}"`;

		try {
			const d = await pb.collection('bouts').getFullList(200, {
				filter,
				expand: 'opponent',
				sort: 'opponent.name,-created',
				fields: 'id,expand.opponent.id,expand.opponent.name,expand.opponent.vorname'
			});
			const map = new Map<string, any>();
			d.forEach((item: any) => {
				const opp = item.expand.opponent;
				if (!map.has(opp.id)) map.set(opp.id, opp);
			});
			opponentsData = Array.from(map.values());
		} catch (e) {
			console.error(e);
			opponentsData = [];
		} finally {
			loadingOpponents = false;
		}
	}

	async function onYearChange() {
		await Promise.all([loadRankings(), loadOpponents(), loadElo()]);
	}

	// SvelteKit reuses this component instance when navigating between two
	// `/wrestler/[id]` pages (same route, different id) rather than
	// remounting it, so onMount alone would only ever load the first
	// wrestler viewed. Track wrestler.id explicitly so this reruns for
	// every wrestler, including the first one.
	$effect(() => {
		void wrestler.id;
		selectedYear = 'Alle';
		loadElo();
		loadRankings();
		loadOpponents();
	});
</script>

<svelte:head>
	<title>{wrestler.vorname} {wrestler.name} - Tellbow</title>
	<meta name="description" content="{t(locale, 'wrestler.metaDescriptionPrefix')} {wrestler.vorname} {wrestler.name}." />
	<meta property="og:title" content="{wrestler.vorname} {wrestler.name} - Tellbow" />
	<meta property="og:description" content="{t(locale, 'wrestler.metaDescriptionPrefix')} {wrestler.vorname} {wrestler.name}." />
</svelte:head>

<!-- Hero -->
<div class="bg-surface-low rounded-2xl px-6 py-8 md:px-10 md:py-10 mb-4">
	<p class="text-xs font-semibold uppercase tracking-widest text-outline mb-2">{t(locale, 'wrestler.profile')}</p>
	<h1 class="text-4xl md:text-5xl font-extrabold tracking-tight text-foreground leading-none">
		{wrestler.vorname} {wrestler.name}
	</h1>

	<div class="flex flex-wrap items-center gap-x-2 gap-y-1 mt-3 text-sm text-outline">
		{#if wrestler.expand?.club}
			<a href="/associations/club/{wrestler.expand.club.id}" class="hover:text-foreground transition-colors">
				{wrestler.expand.club.name}
			</a>
		{/if}
		{#if wrestler.expand?.club?.expand?.canton}
			<span>·</span>
			<span>{wrestler.expand.club.expand.canton.name}</span>
		{/if}
		{#if wrestler.expand?.club?.expand?.canton?.expand?.association}
			<span>·</span>
			<span>{wrestler.expand.club.expand.canton.expand.association.abbreviation}</span>
		{/if}
		{#if wrestler.expand?.metadata?.website}
			<span>·</span>
			<a href={wrestler.expand.metadata.website} target="_blank" rel="noopener" class="hover:text-foreground transition-colors underline underline-offset-2">{t(locale, 'wrestler.website')}</a>
		{/if}
	</div>

	<div class="grid grid-cols-2 md:grid-cols-4 gap-3 mt-6">
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">{t(locale, 'wrestler.eloRating')}</p>
			<p class="text-2xl font-bold tracking-tight">{eloData?.rating ?? '…'}</p>
		</div>
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">{t(locale, 'wrestler.yearOfBirth')}</p>
			<p class="text-2xl font-bold tracking-tight">{wrestler.year}</p>
		</div>
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">{t(locale, 'wrestler.wreaths')}</p>
			<p class="text-base font-bold tracking-tight mt-1">{wreath1}* · {wreath2}** · {wreath3}***</p>
		</div>
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">{t(locale, 'wrestler.status')}</p>
			{#if wrestler.expand?.status}
				<p class="text-sm font-semibold mt-1">{wrestler.expand.status.status}</p>
				<p class="text-xs text-outline">{wrestler.category ? t(locale, 'wrestler.active') : t(locale, 'wrestler.inactive')}</p>
			{:else}
				<p class="text-sm font-semibold mt-1">—</p>
			{/if}
		</div>
	</div>
</div>

<!-- Stats + Charts -->
{#if !loadingRankings}
	<WrestlerStatsCharts {rankingsData} {selectedYear} {locale} />
{/if}

<!-- Resultate -->
<div class="card mb-4">
	<div class="flex items-center justify-between mb-4 flex-wrap gap-2">
		<h3 class="card-title mb-0">{t(locale, 'rankings.resultsTitle')}</h3>
		<div class="flex items-center gap-2">
			<label class="text-xs text-outline font-medium" for="year-select">{t(locale, 'wrestler.yearLabel')}</label>
			<select
				id="year-select"
				class="select-input"
				bind:value={selectedYear}
				onchange={onYearChange}
			>
				{#each YEARS as y}
					<option value={y}>{y === 'Alle' ? t(locale, 'common.all') : y}</option>
				{/each}
			</select>
		</div>
	</div>

	{#if loadingRankings}
		<div class="text-center py-10"><div class="spinner mx-auto"></div></div>
	{:else if rankingsData.length === 0}
		<p class="text-outline text-sm py-4">{t(locale, 'wrestler.noResultsAvailable')}</p>
	{:else}
		<div class="overflow-x-auto">
			<table class="data-table w-full">
				<thead>
					<tr>
						<th>{t(locale, 'rankings.colSchwingfest')}</th>
						<th class="hidden md:table-cell">{t(locale, 'rankings.colYear')}</th>
						<th>{t(locale, 'rankings.rank')}</th>
						<th>{t(locale, 'wrestler.colPoints')}</th>
						<th>{t(locale, 'rankings.result')}</th>
						<th class="hidden md:table-cell">{t(locale, 'rankings.finalRound')}</th>
						<th class="hidden md:table-cell">{t(locale, 'rankings.wreath')}</th>
					</tr>
				</thead>
				<tbody>
					{#each rankingsData as r}
						<tr>
							<td class="font-medium">
								<a
									href="/wrestler/{wrestler.id}-{r.expand?.place?.id}"
									class="hover:underline"
								>
									{r.expand?.place?.name ?? '-'}
								</a>
							</td>
							<td class="hidden md:table-cell text-outline">{r.expand?.place?.year ?? '-'}</td>
							<td class="font-semibold">{r.rank}{r.rank2}</td>
							<td>{r.points}</td>
							<td class="font-mono text-xs tracking-wider">
								{#each r.result.split('') as char}
									{#if char === '+'}
										<span class="text-on-tertiary-fixed-variant dark:text-tertiary-fixed font-bold">+</span>
									{:else if char === 'o'}
										<span class="text-on-error-container dark:text-error font-bold">o</span>
									{:else}
										<span class="text-secondary-solid">-</span>
									{/if}
								{/each}
							</td>
							<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
							<td class="hidden md:table-cell">
								{r.wreath ? '🏆' : ''}
								{r.status === 'Unfall' ? '🩹' : ''}
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</div>

<WrestlerHeadToHead wrestlerId={wrestler.id} {opponentsData} {loadingOpponents} {locale} />

<WrestlerTopOpponents wrestlerId={wrestler.id} {locale} />
