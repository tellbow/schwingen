<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import {
		Chart,
		BubbleController, PointElement, LinearScale,
		Legend, Tooltip, Title
	} from 'chart.js';

	Chart.register(BubbleController, PointElement, LinearScale, Legend, Tooltip, Title);

	let { data } = $props();
	const wrestler = $derived(data.wrestler);
	const opponent = $derived(data.opponent);
	const rankingsW = $derived(data.rankingsW);
	const rankingsO = $derived(data.rankingsO);
	const commonBouts = $derived(data.commonBouts);

	let bubbleCanvas = $state<HTMLCanvasElement | null>(null);
	let bubbleChart: Chart | null = null;

	// Compute stats
	function calcStats(rankings: any[]) {
		const filtered = rankings.filter((r) => r.status !== 'Unfall');
		const ranks = filtered.map((r) => parseInt(r.rank?.replace(/\D/g, '') || '0') || 0).filter((v) => v > 0);
		const points = filtered.map((r) => parseFloat(r.points) || 0).filter((v) => v > 0);
		const wreaths = filtered.filter((r) => r.wreath).length;
		const finals = filtered.filter((r) => r.final).length;

		return {
			avgRank: ranks.length ? (ranks.reduce((a, b) => a + b, 0) / ranks.length).toFixed(2) : '-',
			avgPoints: points.length ? (points.reduce((a, b) => a + b, 0) / points.length).toFixed(2) : '-',
			wreaths,
			finals,
			events: filtered.length
		};
	}

	const statsW = $derived(calcStats(rankingsW));
	const statsO = $derived(calcStats(rankingsO));

	onMount(() => {
		if (bubbleCanvas && rankingsW.length && rankingsO.length) {
			const wPoints = rankingsW.filter((r) => r.status !== 'Unfall').map((r) => ({
				x: parseFloat(r.points) || 0,
				y: parseInt(r.rank?.replace(/\D/g, '') || '0') || 0,
				r: 5
			}));
			const oPoints = rankingsO.filter((r) => r.status !== 'Unfall').map((r) => ({
				x: parseFloat(r.points) || 0,
				y: parseInt(r.rank?.replace(/\D/g, '') || '0') || 0,
				r: 5
			}));

			bubbleChart = new Chart(bubbleCanvas, {
				type: 'bubble',
				data: {
					datasets: [
						{
							label: `${wrestler.name} ${wrestler.vorname}`,
							data: wPoints,
							backgroundColor: 'rgba(34, 197, 94, 0.5)'
						},
						{
							label: `${opponent.name} ${opponent.vorname}`,
							data: oPoints,
							backgroundColor: 'rgba(239, 68, 68, 0.5)'
						}
					]
				},
				options: {
					responsive: true,
					scales: {
						x: { title: { display: true, text: 'Punkte' } },
						y: { title: { display: true, text: 'Rang' }, reverse: true, min: 1 }
					}
				}
			});
		}
	});
</script>

<svelte:head>
	<title>{wrestler.vorname} {wrestler.name} vs {opponent.vorname} {opponent.name} - Tellbow</title>
</svelte:head>

<div class="max-w-4xl mx-auto space-y-4">
	<h1 class="text-xl font-bold">
		<a href="/wrestler/{wrestler.id}" class="underline hover:text-primary">{wrestler.vorname} {wrestler.name}</a>
		vs
		<a href="/wrestler/{opponent.id}" class="underline hover:text-primary">{opponent.vorname} {opponent.name}</a>
	</h1>

	<!-- Stats Comparison -->
	<div class="grid grid-cols-2 gap-4">
		<div class="card">
			<h2 class="font-semibold text-sm mb-2">{wrestler.name} {wrestler.vorname}</h2>
			<div class="text-sm space-y-1">
				<p>Ø Rang: <strong>{statsW.avgRank}</strong></p>
				<p>Ø Punkte: <strong>{statsW.avgPoints}</strong></p>
				<p>Kränze: <strong>{statsW.wreaths}</strong></p>
				<p>Schlussgänge: <strong>{statsW.finals}</strong></p>
				<p>Teilnahmen: <strong>{statsW.events}</strong></p>
			</div>
		</div>
		<div class="card">
			<h2 class="font-semibold text-sm mb-2">{opponent.name} {opponent.vorname}</h2>
			<div class="text-sm space-y-1">
				<p>Ø Rang: <strong>{statsO.avgRank}</strong></p>
				<p>Ø Punkte: <strong>{statsO.avgPoints}</strong></p>
				<p>Kränze: <strong>{statsO.wreaths}</strong></p>
				<p>Schlussgänge: <strong>{statsO.finals}</strong></p>
				<p>Teilnahmen: <strong>{statsO.events}</strong></p>
			</div>
		</div>
	</div>

	<!-- Bubble Chart -->
	{#if rankingsW.length > 0 && rankingsO.length > 0}
		<div class="card">
			<h2 class="card-title">Punkte vs Rang</h2>
			<canvas bind:this={bubbleCanvas}></canvas>
		</div>
	{/if}

	<!-- Common Bouts -->
	<div class="card">
		<h2 class="card-title">Direkte Begegnungen ({commonBouts.length})</h2>
		{#if commonBouts.length === 0}
			<p class="text-muted-foreground text-sm">Keine direkten Begegnungen gefunden.</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full text-sm">
					<thead>
						<tr>
							<th>Schwingfest</th>
							<th>Jahr</th>
							<th>Punkte</th>
							<th>Resultat</th>
						</tr>
					</thead>
					<tbody>
						{#each commonBouts as b}
							<tr
								class="cursor-pointer"
								onclick={() => goto(`/rankings/${b.expand?.place?.id}`)}
							>
								<td>{b.expand?.place?.name ?? '-'}</td>
								<td>{b.expand?.place?.year ?? '-'}</td>
								<td>{b.points}</td>
								<td class="font-mono">{b.result}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
