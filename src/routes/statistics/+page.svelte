<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

	const YEARS = ['2015', '2016', '2017', '2018', '2019', '2021', '2022', '2023', '2024', '2025', '2026', 'Alle'];

	let selectedYear = $state('Alle');

	$effect(() => {
		selectedYear = data.year;
	});

	function changeYear() {
		goto(localizePath(`/statistics?year=${selectedYear}`, locale), { invalidateAll: true });
	}
</script>

<svelte:head>
	<title>{t(locale, 'statistics.title')} - Tellbow</title>
	<meta name="description" content={t(locale, 'statistics.metaDescription')} />
	<meta property="og:title" content="{t(locale, 'statistics.title')} - Tellbow" />
	<meta property="og:description" content={t(locale, 'statistics.metaDescription')} />
</svelte:head>

<h1 class="sr-only">{t(locale, 'statistics.title')} - Tellbow</h1>

<div class="max-w-4xl mx-auto">
	<!-- Year selector -->
	<div class="flex items-center gap-3 mb-4">
		<label class="font-semibold text-sm" for="year-sel">{t(locale, 'statistics.yearLabel')}</label>
		<select
			id="year-sel"
			class="select-input"
			bind:value={selectedYear}
			onchange={changeYear}
		>
			{#each YEARS as y}
				<option value={y}>{y === 'Alle' ? t(locale, 'common.all') : y}</option>
			{/each}
		</select>
	</div>

	<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
		<!-- ELO Rating -->
		{#if data.year !== 'Alle'}
			<div class="card">
				<h2 class="card-title">{t(locale, 'statistics.topEloTitle')}</h2>
				<p class="text-xs text-outline mb-2">{t(locale, 'statistics.topEloSubtitle')}</p>
				{#if data.eloData.length === 0}
					<p class="text-outline text-sm">{t(locale, 'statistics.noDataAvailable')}</p>
				{:else}
					<table class="w-full text-sm">
						<tbody>
							{#each data.eloData as item, i}
								<tr class="hover:bg-surface-high border-b border-outline-variant/20">
									<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
									<td class="py-1">
										<a href="/wrestler/{item.expand?.wrestler?.id}" class="hover:underline">
											{item.expand?.wrestler?.name} {item.expand?.wrestler?.vorname}
										</a>
									</td>
									<td class="py-1 text-right font-mono">{item.rating}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				{/if}
			</div>
		{/if}

		<!-- Average Rank -->
		<div class="card">
			<h2 class="card-title">{t(locale, 'statistics.topAvgRankTitle')}</h2>
			<p class="text-xs text-outline mb-2">{t(locale, 'statistics.fiveEventsSubtitle')}</p>
			{#if data.averageRank.length === 0}
				<p class="text-outline text-sm">{t(locale, 'statistics.noDataAvailable')}</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.averageRank as item, i}
							<tr class="hover:bg-surface-high border-b border-outline-variant/20">
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">
									<a href="/wrestler/{item.wid}" class="hover:underline">{item.name} {item.vorname}</a>
								</td>
								<td class="py-1 text-right font-mono">{item.avgRank}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Average Points -->
		<div class="card">
			<h2 class="card-title">{t(locale, 'statistics.topAvgPointsTitle')}</h2>
			<p class="text-xs text-outline mb-2">{t(locale, 'statistics.fiveEventsSubtitle')}</p>
			{#if data.averagePoints.length === 0}
				<p class="text-outline text-sm">{t(locale, 'statistics.noDataAvailable')}</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.averagePoints as item, i}
							<tr class="hover:bg-surface-high border-b border-outline-variant/20">
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">
									<a href="/wrestler/{item.wid}" class="hover:underline">{item.name} {item.vorname}</a>
								</td>
								<td class="py-1 text-right font-mono">{item.avgPoints}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Most Wins -->
		<div class="card">
			<h2 class="card-title">{t(locale, 'statistics.topWinsTitle')}</h2>
			{#if data.mostWins.length === 0}
				<p class="text-outline text-sm">{t(locale, 'statistics.noDataAvailable')}</p>
			{:else}
				<table class="w-full text-sm">
					<thead>
						<tr class="text-outline text-xs border-b border-outline-variant/20">
							<th class="py-1 text-left w-6">#</th>
							<th class="py-1 text-left">{t(locale, 'statistics.colSchwinger')}</th>
							<th class="py-1 text-right">{t(locale, 'statistics.colWins')}</th>
							<th class="py-1 text-right">{t(locale, 'statistics.colWithWreath')}</th>
						</tr>
					</thead>
					<tbody>
						{#each data.mostWins as item, i}
							<tr class="hover:bg-surface-high border-b border-outline-variant/20">
								<td class="py-1 text-center font-bold">{i + 1}</td>
								<td class="py-1">
									<a href="/wrestler/{item.id}" class="hover:underline">{item.name} {item.vorname}</a>
								</td>
								<td class="py-1 text-right font-mono">{item.wins}</td>
								<td class="py-1 text-right font-mono">{item.wreath}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Most Wreaths -->
		<div class="card">
			<h2 class="card-title">{t(locale, 'statistics.topWreathsTitle')}</h2>
			{#if data.mostWreaths.length === 0}
				<p class="text-outline text-sm">{t(locale, 'statistics.noDataAvailable')}</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.mostWreaths as item, i}
							<tr class="hover:bg-surface-high border-b border-outline-variant/20">
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">
									<a href="/wrestler/{item.id}" class="hover:underline">{item.name} {item.vorname}</a>
								</td>
								<td class="py-1 text-right font-mono">{item.wreath}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Most Places Attended -->
		<div class="card">
			<h2 class="card-title">{t(locale, 'statistics.topPlacesTitle')}</h2>
			{#if data.mostPlacesAttended.length === 0}
				<p class="text-outline text-sm">{t(locale, 'statistics.noDataAvailable')}</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.mostPlacesAttended as item, i}
							<tr class="hover:bg-surface-high border-b border-outline-variant/20">
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">
									<a href="/wrestler/{item.id}" class="hover:underline">{item.name} {item.vorname}</a>
								</td>
								<td class="py-1 text-right font-mono">{item.placesAttended}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Draw/Decision Ratio -->
		<div class="card">
			<h2 class="card-title">{t(locale, 'statistics.drawRatioTitle')}</h2>
			<p class="text-4xl font-bold text-foreground">{data.drawDecisionRatio}%</p>
			<p class="text-xs text-outline mt-1">{t(locale, 'statistics.drawRatioCaptionPrefix')} {data.year === 'Alle' ? t(locale, 'statistics.allYears') : data.year}</p>
		</div>
	</div>
</div>
