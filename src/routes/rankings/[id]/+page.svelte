<script lang="ts">
	import { page } from '$app/stores';
	import { t, type Locale } from '$lib/i18n/index.svelte';
	import RankingStatistics from '$lib/components/rankings/ranking-statistics.svelte';

	let { data } = $props();
	const place = $derived(data.place);
	const rankings = $derived(data.rankings);
	const locale = $derived($page.data.locale as Locale);

	let activeTab = $state<'rangliste' | 'statistik'>('rangliste');
</script>

<svelte:head>
	<title>{place.name} {place.year} - {t(locale, 'rankings.detailTitleSuffix')}</title>
	<meta name="description" content="{t(locale, 'rankings.detailDescriptionPrefix')} {place.name} {place.year}." />
	<meta property="og:title" content="{place.name} {place.year} - {t(locale, 'rankings.detailTitleSuffix')}" />
	<meta property="og:description" content="{t(locale, 'rankings.detailDescriptionPrefix')} {place.name} {place.year}." />
</svelte:head>

<div class="max-w-4xl mx-auto">
	<div class="card mb-4">
		<h1 class="text-xl font-bold">{place.name}</h1>
		<p class="text-sm text-muted-foreground mt-1">
			{place.year} &nbsp;|&nbsp; {place.location ?? ''}
			{#if place.expand?.placeType?.type}
				&nbsp;|&nbsp; {place.expand.placeType.type}
			{/if}
		</p>
	</div>

	<div class="card">
		<h2 class="card-title">{t(locale, 'rankings.resultsTitle')}</h2>
		<div class="flex gap-2 border-b border-border mb-4">
			<button
				class="px-3 py-2 text-sm font-medium border-b-2 -mb-px transition-colors"
				class:border-primary={activeTab === 'rangliste'}
				class:text-primary={activeTab === 'rangliste'}
				class:border-transparent={activeTab !== 'rangliste'}
				class:text-outline={activeTab !== 'rangliste'}
				onclick={() => (activeTab = 'rangliste')}
			>
				{t(locale, 'rankings.tabRangliste')}
			</button>
			<button
				class="px-3 py-2 text-sm font-medium border-b-2 -mb-px transition-colors"
				class:border-primary={activeTab === 'statistik'}
				class:text-primary={activeTab === 'statistik'}
				class:border-transparent={activeTab !== 'statistik'}
				class:text-outline={activeTab !== 'statistik'}
				onclick={() => (activeTab = 'statistik')}
			>
				{t(locale, 'rankings.tabStatistik')}
			</button>
		</div>

		{#if activeTab === 'rangliste'}
			<div class="overflow-x-auto">
				<table class="data-table w-full">
					<thead>
						<tr>
							<th>{t(locale, 'rankings.rank')}</th>
							<th>{t(locale, 'rankings.points')}</th>
							<th>{t(locale, 'wrestler.name')}</th>
							<th class="hidden md:table-cell">{t(locale, 'wrestler.firstName')}</th>
							<th>{t(locale, 'rankings.result')}</th>
							<th class="hidden md:table-cell">{t(locale, 'rankings.finalRound')}</th>
							<th class="hidden md:table-cell">{t(locale, 'rankings.wreath')}</th>
							<th class="hidden md:table-cell">{t(locale, 'rankings.colStatus')}</th>
						</tr>
					</thead>
					<tbody>
						{#if rankings.length === 0}
							<tr><td colspan="8" class="text-center py-8 text-muted-foreground">{t(locale, 'rankings.noResultsFound')}</td></tr>
						{/if}
						{#each rankings as r}
							<tr>
								<td>{r.rank}{r.rank2}</td>
								<td>{r.points}</td>
								<td class="font-medium">
									<a href="/wrestler/{r.expand?.wrestler?.id}" class="hover:underline">
										{r.expand?.wrestler?.name ?? '-'}
									</a>
									<span class="md:hidden text-muted-foreground text-xs"> {r.expand?.wrestler?.vorname ?? ''}</span>
								</td>
								<td class="hidden md:table-cell">{r.expand?.wrestler?.vorname ?? '-'}</td>
								<td class="font-mono text-xs">{r.result}</td>
								<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
								<td class="hidden md:table-cell">{r.wreath ? '🏆' : ''}</td>
								<td class="hidden md:table-cell text-xs">{r.status ?? ''}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{:else}
			<RankingStatistics {rankings} {locale} />
		{/if}
	</div>
</div>
