<script lang="ts">
	import { onDestroy } from 'svelte';
	import { page } from '$app/stores';
	import type { Chart } from 'chart.js';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { data } = $props();
	const wrestler = $derived(data.wrestler);
	const opponent = $derived(data.opponent);
	const rankingsW = $derived(data.rankingsW);
	const rankingsO = $derived(data.rankingsO);
	const commonBouts = $derived(data.commonBouts);
	const locale = $derived($page.data.locale as Locale);

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

	let ChartJS: typeof Chart;

	async function ensureChartJS() {
		if (ChartJS) return;
		const { Chart: ChartJSImport, BubbleController, PointElement, LinearScale, Legend, Tooltip, Title } =
			await import('chart.js');
		ChartJS = ChartJSImport;
		ChartJS.register(BubbleController, PointElement, LinearScale, Legend, Tooltip, Title);
	}

	function drawBubbleChart() {
		if (!bubbleCanvas || !rankingsW.length || !rankingsO.length) return;

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

		bubbleChart?.destroy();
		bubbleChart = new ChartJS(bubbleCanvas, {
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
					x: { title: { display: true, text: t(locale, 'rankings.points') } },
					y: { title: { display: true, text: t(locale, 'rankings.rank') }, reverse: true, min: 1 }
				}
			}
		});
	}

	// SvelteKit reuses this component instance when navigating between two
	// head2head comparisons (same route, different wid-oid), so onMount
	// alone would only ever draw the chart for the first pair viewed.
	$effect(() => {
		rankingsW;
		rankingsO;
		locale;
		ensureChartJS().then(drawBubbleChart);
	});

	onDestroy(() => {
		bubbleChart?.destroy();
	});
</script>

<svelte:head>
	<title>{wrestler.vorname} {wrestler.name} {t(locale, 'head2head.vs')} {opponent.vorname} {opponent.name} - Tellbow</title>
	<meta name="description" content="{t(locale, 'head2head.metaDescriptionPrefix')} {wrestler.vorname} {wrestler.name} {t(locale, 'head2head.and')} {opponent.vorname} {opponent.name}." />
	<meta property="og:title" content="{wrestler.vorname} {wrestler.name} {t(locale, 'head2head.vs')} {opponent.vorname} {opponent.name} - Tellbow" />
	<meta property="og:description" content="{t(locale, 'head2head.metaDescriptionPrefix')} {wrestler.vorname} {wrestler.name} {t(locale, 'head2head.and')} {opponent.vorname} {opponent.name}." />
</svelte:head>

<div class="max-w-4xl mx-auto space-y-4">
	<h1 class="text-xl font-bold">
		<a href="/wrestler/{wrestler.id}" class="underline hover:text-primary">{wrestler.vorname} {wrestler.name}</a>
		{t(locale, 'head2head.vs')}
		<a href="/wrestler/{opponent.id}" class="underline hover:text-primary">{opponent.vorname} {opponent.name}</a>
	</h1>

	<!-- Stats Comparison -->
	<div class="grid grid-cols-2 gap-4">
		<div class="card">
			<h2 class="font-semibold text-sm mb-2">{wrestler.name} {wrestler.vorname}</h2>
			<div class="text-sm space-y-1">
				<p>{t(locale, 'wrestler.avgRank')}: <strong>{statsW.avgRank}</strong></p>
				<p>{t(locale, 'wrestler.avgPoints')}: <strong>{statsW.avgPoints}</strong></p>
				<p>{t(locale, 'rankings.wreath')}: <strong>{statsW.wreaths}</strong></p>
				<p>{t(locale, 'head2head.finalRoundsLabel')}: <strong>{statsW.finals}</strong></p>
				<p>{t(locale, 'head2head.eventsLabel')}: <strong>{statsW.events}</strong></p>
			</div>
		</div>
		<div class="card">
			<h2 class="font-semibold text-sm mb-2">{opponent.name} {opponent.vorname}</h2>
			<div class="text-sm space-y-1">
				<p>{t(locale, 'wrestler.avgRank')}: <strong>{statsO.avgRank}</strong></p>
				<p>{t(locale, 'wrestler.avgPoints')}: <strong>{statsO.avgPoints}</strong></p>
				<p>{t(locale, 'rankings.wreath')}: <strong>{statsO.wreaths}</strong></p>
				<p>{t(locale, 'head2head.finalRoundsLabel')}: <strong>{statsO.finals}</strong></p>
				<p>{t(locale, 'head2head.eventsLabel')}: <strong>{statsO.events}</strong></p>
			</div>
		</div>
	</div>

	<!-- Bubble Chart -->
	{#if rankingsW.length > 0 && rankingsO.length > 0}
		<div class="card">
			<h2 class="card-title">{t(locale, 'head2head.pointsVsRankTitle')}</h2>
			<canvas bind:this={bubbleCanvas}></canvas>
		</div>
	{/if}

	<!-- Common Bouts -->
	<div class="card">
		<h2 class="card-title">{t(locale, 'head2head.commonBoutsTitle')} ({commonBouts.length})</h2>
		{#if commonBouts.length === 0}
			<p class="text-muted-foreground text-sm">{t(locale, 'head2head.noCommonBouts')}</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full text-sm">
					<thead>
						<tr>
							<th>{t(locale, 'rankings.colSchwingfest')}</th>
							<th>{t(locale, 'rankings.colYear')}</th>
							<th>{t(locale, 'rankings.points')}</th>
							<th>{t(locale, 'rankings.result')}</th>
						</tr>
					</thead>
					<tbody>
						{#each commonBouts as b}
							<tr>
								<td>
									<a href="/rankings/{b.expand?.place?.id}" class="hover:underline">
										{b.expand?.place?.name ?? '-'}
									</a>
								</td>
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
