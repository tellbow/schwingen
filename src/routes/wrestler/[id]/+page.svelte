<script lang="ts">
	import type { BoutRecord, WithExpand, WrestlerRecord } from '#lib/types/pocketbase.js';
	import { untrack } from 'svelte';
	import { page } from '$app/state';
	import { getClientPb } from '#lib/pb.js';
	import {
		PROFILE_YEARS,
		countWreaths,
		fetchWrestlerElo,
		fetchWrestlerRankings,
		type ProfileYear
	} from '#lib/utils/wrestler-profile.js';
	import { t, type Locale } from '#lib/i18n/index.svelte.js';
	import WreathMark from '#lib/components/rankings/wreath-mark.svelte';
	import WrestlerStatsCharts from '#lib/components/wrestler/wrestler-stats-charts.svelte';
	import WrestlerHeadToHead from '#lib/components/wrestler/wrestler-head-to-head.svelte';
	import WrestlerTopOpponents from '#lib/components/wrestler/wrestler-top-opponents.svelte';

	let { data } = $props();
	const wrestler = $derived(data.wrestler);
	const locale = $derived(page.data.locale as Locale);

	let selectedYear = $state<ProfileYear>('Alle');
	let rankingsData = $derived(data.rankings);
	let eloData = $derived<{ rating: number | string }>(data.elo);
	const wreaths = $derived(countWreaths(rankingsData));
	const club = $derived(wrestler.expand?.club?.name);
	const metaTitle = $derived(
		`${wrestler.vorname} ${wrestler.name} – ${t(locale, 'wrestler.metaRole')}${club ? `, ${club}` : ''} - Tellbow`
	);
	const metaDescription = $derived(
		`${t(locale, 'wrestler.metaDescriptionPrefix')} ${wrestler.vorname} ${wrestler.name}` +
			`${club ? ` (${club})` : ''}: ${data.rankings.length} ${t(locale, 'wrestler.metaFestivals')}, ` +
			`${countWreaths(data.rankings).reduce((a, b) => a + b, 0)} ${t(locale, 'wrestler.metaWreaths')}` +
			`${data.elo.rating === '-' ? '' : `, ELO ${data.elo.rating}`}.`
	);
	let opponentsData = $state<WrestlerRecord[]>([]);

	let loadingRankings = $state(false);
	let loadingOpponents = $state(true);

	async function loadElo() {
		eloData = await fetchWrestlerElo(getClientPb(), wrestler.id, selectedYear);
	}

	async function loadRankings() {
		loadingRankings = true;
		try {
			rankingsData = await fetchWrestlerRankings(getClientPb(), wrestler.id, selectedYear);
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
			const d = await pb.collection('bouts').getFullList<WithExpand<BoutRecord, 'opponent'>>(200, {
				filter,
				expand: 'opponent',
				sort: 'opponent.name,-created',
				fields: 'id,expand.opponent.id,expand.opponent.name,expand.opponent.vorname'
			});
			const opponents = d.map((item) => item.expand.opponent);
			opponentsData = opponents.filter(
				(opp, i) => opponents.findIndex((o) => o.id === opp.id) === i
			);
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
		untrack(() => {
			selectedYear = 'Alle';
			loadOpponents();
		});
	});
</script>

<svelte:head>
	<title>{metaTitle}</title>
	<meta name="description" content={metaDescription} />
	<meta property="og:title" content={metaTitle} />
	<meta property="og:description" content={metaDescription} />
</svelte:head>

<!-- Hero -->

<div class="mb-4 rounded-2xl bg-surface-low px-6 py-8 md:px-10 md:py-10">
	<p class="mb-2 text-xs font-semibold tracking-widest text-outline uppercase">
		{t(locale, 'wrestler.profile')}
	</p>

	<h1 class="text-4xl leading-none font-extrabold tracking-tight text-foreground md:text-5xl">
		{wrestler.vorname}
		{wrestler.name}
	</h1>

	<div class="mt-3 flex flex-wrap items-center gap-x-2 gap-y-1 text-sm text-outline">
		{#if wrestler.expand?.club}
			<a
				href="/associations/club/{wrestler.expand.club.id}"
				class="transition-colors hover:text-foreground"
			>
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
			<a
				href={wrestler.expand.metadata.website}
				target="_blank"
				rel="noopener"
				class="underline underline-offset-2 transition-colors hover:text-foreground"
				>{t(locale, 'wrestler.website')}</a
			>
		{/if}
	</div>

	<div class="mt-6 grid grid-cols-2 gap-3 md:grid-cols-4">
		<div class="rounded-xl bg-surface-lowest p-4">
			<p class="mb-1 text-xs text-outline">{t(locale, 'wrestler.eloRating')}</p>
			<p class="text-2xl font-bold tracking-tight">{eloData?.rating ?? '…'}</p>
		</div>
		<div class="rounded-xl bg-surface-lowest p-4">
			<p class="mb-1 text-xs text-outline">{t(locale, 'wrestler.yearOfBirth')}</p>
			<p class="text-2xl font-bold tracking-tight">{wrestler.year}</p>
		</div>
		<div class="rounded-xl bg-surface-lowest p-4">
			<p class="mb-1 text-xs text-outline">{t(locale, 'wrestler.wreaths')}</p>
			<p class="mt-1 text-base font-bold tracking-tight">
				{wreaths[0]}* · {wreaths[1]}** · {wreaths[2]}***
			</p>
		</div>
		<div class="rounded-xl bg-surface-lowest p-4">
			<p class="mb-1 text-xs text-outline">{t(locale, 'wrestler.status')}</p>
			{#if wrestler.expand?.status}
				<p class="mt-1 text-sm font-semibold">{wrestler.expand.status.status}</p>
				<p class="text-xs text-outline">
					{wrestler.category ? t(locale, 'wrestler.active') : t(locale, 'wrestler.inactive')}
				</p>
			{:else}
				<p class="mt-1 text-sm font-semibold">—</p>
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
	<div class="mb-4 flex flex-wrap items-center justify-between gap-2">
		<h3 class="card-title mb-0">{t(locale, 'rankings.resultsTitle')}</h3>
		<div class="flex items-center gap-2">
			<label class="text-xs font-medium text-outline" for="year-select"
				>{t(locale, 'wrestler.yearLabel')}</label
			>
			<select
				id="year-select"
				class="select-input"
				bind:value={selectedYear}
				onchange={onYearChange}
			>
				{#each PROFILE_YEARS as y (y)}
					<option value={y}>{y === 'Alle' ? t(locale, 'common.all') : y}</option>
				{/each}
			</select>
		</div>
	</div>

	{#if loadingRankings}
		<div class="py-10 text-center"><div class="spinner mx-auto"></div></div>
	{:else if rankingsData.length === 0}
		<p class="py-4 text-sm text-outline">{t(locale, 'wrestler.noResultsAvailable')}</p>
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
					{#each rankingsData as r (r.id)}
						<tr>
							<td class="font-medium">
								<a href="/wrestler/{wrestler.id}-{r.expand?.place?.id}" class="hover:underline">
									{r.expand?.place?.name ?? '-'}
								</a>
							</td>
							<td class="hidden text-outline md:table-cell">{r.expand?.place?.year ?? '-'}</td>
							<td class="font-semibold">{r.rank}{r.rank2}</td>
							<td>{r.points}</td>
							<td class="font-mono text-xs tracking-wider">
								{#each r.result.split('') as char, i (i)}
									{#if char === '+'}
										<span class="font-bold text-on-tertiary-fixed-variant dark:text-tertiary-fixed"
											>+</span
										>
									{:else if char === 'o'}
										<span class="font-bold text-on-error-container dark:text-error">o</span>
									{:else}
										<span class="text-secondary-solid">-</span>
									{/if}
								{/each}
							</td>
							<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
							<td class="hidden md:table-cell">
								{#if r.wreath}
									<WreathMark {locale} />
								{/if}

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
