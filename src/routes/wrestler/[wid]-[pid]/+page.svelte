<script lang="ts">
	import { page } from '$app/stores';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { data } = $props();
	const wrestler = $derived(data.wrestler);
	const place = $derived(data.place);
	const ranking = $derived(data.ranking);
	const bouts = $derived(data.bouts);
	const locale = $derived($page.data.locale as Locale);
</script>

<svelte:head>
	<title>{wrestler.vorname} {wrestler.name}, {place.name} - Tellbow</title>
	<meta name="description" content="{t(locale, 'wrestler.resultsAtMetaDescriptionPrefix')} {wrestler.vorname} {wrestler.name} {t(locale, 'wrestler.resultsAtMetaDescriptionInfix')} {place.name}." />
	<meta property="og:title" content="{wrestler.vorname} {wrestler.name}, {place.name} - Tellbow" />
	<meta property="og:description" content="{t(locale, 'wrestler.resultsAtMetaDescriptionPrefix')} {wrestler.vorname} {wrestler.name} {t(locale, 'wrestler.resultsAtMetaDescriptionInfix')} {place.name}." />
</svelte:head>

<div class="max-w-4xl mx-auto space-y-4">
	<div class="card">
		<h1 class="text-xl font-bold">
			<a href="/wrestler/{wrestler.id}" class="hover:text-primary transition-colors">
				{wrestler.vorname} {wrestler.name}
			</a>
			@ {place.name}
		</h1>
		<p class="text-sm text-muted-foreground mt-1">
			{place.year} &nbsp;|&nbsp; {place.location ?? ''}
			{#if place.expand?.placeType?.type}
				&nbsp;|&nbsp; {place.expand.placeType.type}
			{/if}
		</p>

		{#if ranking}
			<div class="flex flex-wrap gap-4 mt-4 text-sm">
				<div>
					<p class="text-xs text-outline">{t(locale, 'rankings.rank')}</p>
					<p class="font-semibold">{ranking.rank}{ranking.rank2}</p>
				</div>
				<div>
					<p class="text-xs text-outline">{t(locale, 'rankings.points')}</p>
					<p class="font-semibold">{ranking.points}</p>
				</div>
				<div>
					<p class="text-xs text-outline">{t(locale, 'rankings.result')}</p>
					<p class="font-mono">{ranking.result}</p>
				</div>
				<div>
					<p class="text-xs text-outline">{t(locale, 'wrestler.finalWreathLabel')}</p>
					<p class="font-semibold">{ranking.final ? '🏁' : ''} {ranking.wreath ? '🏆' : ''}</p>
				</div>
			</div>
		{/if}
	</div>

	<div class="card">
		<h2 class="card-title">{t(locale, 'wrestler.roundsTitle')} ({bouts.length})</h2>
		{#if bouts.length === 0}
			<p class="text-muted-foreground text-sm">{t(locale, 'wrestler.noBoutsFound')}</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full">
					<thead>
						<tr>
							<th>{t(locale, 'rankings.gang')}</th>
							<th>{t(locale, 'rankings.result')}</th>
							<th>{t(locale, 'rankings.points')}</th>
							<th>{t(locale, 'rankings.opponent')}</th>
						</tr>
					</thead>
					<tbody>
						{#each bouts as b}
							<tr>
								<td>{b.fight_round}</td>
								<td class="font-mono text-xs tracking-wider">
									{#each b.result.split('') as char}
										{#if char === '+'}
											<span class="text-on-tertiary-fixed-variant dark:text-tertiary-fixed font-bold">+</span>
										{:else if char === 'o'}
											<span class="text-on-error-container dark:text-error font-bold">o</span>
										{:else}
											<span class="text-secondary-solid">-</span>
										{/if}
									{/each}
								</td>
								<td>{b.points}</td>
								<td class="font-medium">
									<a href="/wrestler/{b.expand?.opponent?.id}-{place.id}" class="hover:underline">
										{b.expand?.opponent?.name ?? '-'} {b.expand?.opponent?.vorname ?? ''}
									</a>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
