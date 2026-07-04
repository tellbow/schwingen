<script lang="ts">
	import { goto } from '$app/navigation';
	import { t } from '$lib/i18n/index.svelte';
	import RankingStatistics from '$lib/components/rankings/ranking-statistics.svelte';

	let { data } = $props();
	const place = $derived(data.place);
	const rankings = $derived(data.rankings);

	let activeTab = $state<'rangliste' | 'statistik'>('rangliste');
</script>

<svelte:head>
	<title>{place.name} {place.year} - Rangliste - Tellbow</title>
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
		<h2 class="card-title">{t('rankings.resultsTitle')}</h2>
		<div class="flex gap-2 border-b border-border mb-4">
			<button
				class="px-3 py-2 text-sm font-medium border-b-2 -mb-px transition-colors"
				class:border-primary={activeTab === 'rangliste'}
				class:text-primary={activeTab === 'rangliste'}
				class:border-transparent={activeTab !== 'rangliste'}
				class:text-outline={activeTab !== 'rangliste'}
				onclick={() => (activeTab = 'rangliste')}
			>
				{t('rankings.tabRangliste')}
			</button>
			<button
				class="px-3 py-2 text-sm font-medium border-b-2 -mb-px transition-colors"
				class:border-primary={activeTab === 'statistik'}
				class:text-primary={activeTab === 'statistik'}
				class:border-transparent={activeTab !== 'statistik'}
				class:text-outline={activeTab !== 'statistik'}
				onclick={() => (activeTab = 'statistik')}
			>
				{t('rankings.tabStatistik')}
			</button>
		</div>

		{#if activeTab === 'rangliste'}
			<div class="overflow-x-auto">
				<table class="data-table w-full">
					<thead>
						<tr>
							<th>Rang</th>
							<th>Punkte</th>
							<th>Name</th>
							<th class="hidden md:table-cell">Vorname</th>
							<th>Resultat</th>
							<th class="hidden md:table-cell">SF</th>
							<th class="hidden md:table-cell">Kranz</th>
							<th class="hidden md:table-cell">Status</th>
						</tr>
					</thead>
					<tbody>
						{#if rankings.length === 0}
							<tr><td colspan="8" class="text-center py-8 text-muted-foreground">Keine Einträge gefunden.</td></tr>
						{/if}
						{#each rankings as r}
							<tr class="cursor-pointer" onclick={() => goto(`/wrestler/${r.expand?.wrestler?.id}`)}>
								<td>{r.rank}{r.rank2}</td>
								<td>{r.points}</td>
								<td class="font-medium">
									{r.expand?.wrestler?.name ?? '-'}
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
			<RankingStatistics {rankings} />
		{/if}
	</div>
</div>
