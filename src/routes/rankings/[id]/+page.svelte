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
	<meta
		name="description"
		content="{t(locale, 'rankings.detailDescriptionPrefix')} {place.name} {place.year}."
	/>
	<meta
		property="og:title"
		content="{place.name} {place.year} - {t(locale, 'rankings.detailTitleSuffix')}"
	/>
	<meta
		property="og:description"
		content="{t(locale, 'rankings.detailDescriptionPrefix')} {place.name} {place.year}."
	/>
</svelte:head>

<div class="mx-auto max-w-4xl">
	<div class="card mb-4">
		<h1 class="text-xl font-bold">{place.name}</h1>
		<p class="mt-1 text-sm text-muted-foreground">
			{place.year} &nbsp;|&nbsp; {place.location ?? ''}
			{#if place.expand?.placeType?.type}
				&nbsp;|&nbsp; {place.expand.placeType.type}
			{/if}
		</p>
	</div>

	<div class="card">
		<h2 class="card-title">{t(locale, 'rankings.resultsTitle')}</h2>
		<div class="mb-4 flex gap-2 border-b border-border">
			<button
				class="-mb-px border-b-2 px-3 py-2 text-sm font-medium transition-colors"
				class:border-primary={activeTab === 'rangliste'}
				class:text-primary={activeTab === 'rangliste'}
				class:border-transparent={activeTab !== 'rangliste'}
				class:text-outline={activeTab !== 'rangliste'}
				onclick={() => (activeTab = 'rangliste')}
			>
				{t(locale, 'rankings.tabRangliste')}
			</button>
			<button
				class="-mb-px border-b-2 px-3 py-2 text-sm font-medium transition-colors"
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
							<tr
								><td colspan="8" class="py-8 text-center text-muted-foreground"
									>{t(locale, 'rankings.noResultsFound')}</td
								></tr
							>
						{/if}
						{#each rankings as r (r.id)}
							<tr>
								<td>{r.rank}{r.rank2}</td>
								<td>{r.points}</td>
								<td class="font-medium">
									<a href="/wrestler/{r.expand?.wrestler?.id}" class="hover:underline">
										{r.expand?.wrestler?.name ?? '-'}
									</a>
									<span class="text-xs text-muted-foreground md:hidden">
										{r.expand?.wrestler?.vorname ?? ''}</span
									>
								</td>
								<td class="hidden md:table-cell">{r.expand?.wrestler?.vorname ?? '-'}</td>
								<td class="font-mono text-xs">{r.result}</td>
								<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
								<td class="hidden md:table-cell">{r.wreath ? '🏆' : ''}</td>
								<td class="hidden text-xs md:table-cell">{r.status ?? ''}</td>
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
