<script lang="ts">
	import { goto } from '$app/navigation';

	let { data } = $props();

	const YEARS = ['2015', '2016', '2017', '2018', '2019', '2021', '2022', '2023', '2024', '2025', 'Alle'];

	let selectedYear = $state('Alle');

	$effect(() => {
		selectedYear = data.year;
	});

	function changeYear() {
		goto(`/statistics?year=${selectedYear}`, { invalidateAll: true });
	}
</script>

<svelte:head>
	<title>Statistiken - Tellbow</title>
	<meta name="description" content="Detaillierte Statistiken und Analysen zu Schweizer Schwingern." />
</svelte:head>

<h1 class="sr-only">Statistiken - Tellbow</h1>

<div class="max-w-4xl mx-auto">
	<!-- Year selector -->
	<div class="flex items-center gap-3 mb-4">
		<label class="font-semibold text-sm" for="year-sel">Jahr:</label>
		<select
			id="year-sel"
			class="select-input"
			bind:value={selectedYear}
			onchange={changeYear}
		>
			{#each YEARS as y}
				<option value={y}>{y}</option>
			{/each}
		</select>
	</div>

	<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
		<!-- ELO Rating -->
		{#if data.year !== 'Alle'}
			<div class="card">
				<h2 class="card-title">Top 5 – ELO-Rating</h2>
				<p class="text-xs text-outline mb-2">Jeweils vom aktuellen Jahr</p>
				{#if data.eloData.length === 0}
					<p class="text-outline text-sm">Keine Daten verfügbar.</p>
				{:else}
					<table class="w-full text-sm">
						<tbody>
							{#each data.eloData as item, i}
								<tr
									class="hover:bg-surface-high cursor-pointer border-b border-outline-variant/20"
									onclick={() => goto(`/wrestler/${item.expand?.wrestler?.id}`)}
								>
									<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
									<td class="py-1">{item.expand?.wrestler?.name} {item.expand?.wrestler?.vorname}</td>
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
			<h2 class="card-title">Top 5 – Ø Rang</h2>
			<p class="text-xs text-outline mb-2">5 Teilnahmen pro Jahr oder mehr</p>
			{#if data.averageRank.length === 0}
				<p class="text-outline text-sm">Keine Daten verfügbar.</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.averageRank as item, i}
							<tr
								class="hover:bg-surface-high cursor-pointer border-b border-outline-variant/20"
								onclick={() => goto(`/wrestler/${item.wid}`)}
							>
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">{item.name} {item.vorname}</td>
								<td class="py-1 text-right font-mono">{item.avgRank}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Average Points -->
		<div class="card">
			<h2 class="card-title">Top 5 – Ø Punkte</h2>
			<p class="text-xs text-outline mb-2">5 Teilnahmen pro Jahr oder mehr</p>
			{#if data.averagePoints.length === 0}
				<p class="text-outline text-sm">Keine Daten verfügbar.</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.averagePoints as item, i}
							<tr
								class="hover:bg-surface-high cursor-pointer border-b border-outline-variant/20"
								onclick={() => goto(`/wrestler/${item.wid}`)}
							>
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">{item.name} {item.vorname}</td>
								<td class="py-1 text-right font-mono">{item.avgPoints}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Most Wins -->
		<div class="card">
			<h2 class="card-title">Top 5 – meiste Siege</h2>
			{#if data.mostWins.length === 0}
				<p class="text-outline text-sm">Keine Daten verfügbar.</p>
			{:else}
				<table class="w-full text-sm">
					<thead>
						<tr class="text-outline text-xs border-b border-outline-variant/20">
							<th class="py-1 text-left w-6">#</th>
							<th class="py-1 text-left">Schwinger</th>
							<th class="py-1 text-right">Siege</th>
							<th class="py-1 text-right">mit Kranz</th>
						</tr>
					</thead>
					<tbody>
						{#each data.mostWins as item, i}
							<tr
								class="hover:bg-surface-high cursor-pointer border-b border-outline-variant/20"
								onclick={() => goto(`/wrestler/${item.id}`)}
							>
								<td class="py-1 text-center font-bold">{i + 1}</td>
								<td class="py-1">{item.name} {item.vorname}</td>
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
			<h2 class="card-title">Top 5 – meiste Kränze</h2>
			{#if data.mostWreaths.length === 0}
				<p class="text-outline text-sm">Keine Daten verfügbar.</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.mostWreaths as item, i}
							<tr
								class="hover:bg-surface-high cursor-pointer border-b border-outline-variant/20"
								onclick={() => goto(`/wrestler/${item.id}`)}
							>
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">{item.name} {item.vorname}</td>
								<td class="py-1 text-right font-mono">{item.wreath}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Most Places Attended -->
		<div class="card">
			<h2 class="card-title">Top 5 – meiste Teilnahmen</h2>
			{#if data.mostPlacesAttended.length === 0}
				<p class="text-outline text-sm">Keine Daten verfügbar.</p>
			{:else}
				<table class="w-full text-sm">
					<tbody>
						{#each data.mostPlacesAttended as item, i}
							<tr
								class="hover:bg-surface-high cursor-pointer border-b border-outline-variant/20"
								onclick={() => goto(`/wrestler/${item.id}`)}
							>
								<td class="py-1 w-6 text-center font-bold">{i + 1}</td>
								<td class="py-1">{item.name} {item.vorname}</td>
								<td class="py-1 text-right font-mono">{item.placesAttended}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			{/if}
		</div>

		<!-- Draw/Decision Ratio -->
		<div class="card">
			<h2 class="card-title">% Gestellte Gänge</h2>
			<p class="text-4xl font-bold text-foreground">{data.drawDecisionRatio}%</p>
			<p class="text-xs text-outline mt-1">Anteil gestellter Gänge {data.year === 'Alle' ? '(alle Jahre)' : data.year}</p>
		</div>
	</div>
</div>
