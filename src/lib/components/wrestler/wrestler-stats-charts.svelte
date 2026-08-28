<script lang="ts">
	import { onDestroy } from 'svelte';
	import type { Chart } from 'chart.js';
	import { getDark } from '$lib/dark-mode.svelte';
	import { t, type Locale } from '$lib/i18n/index.svelte';
	import { computeBoutCounts, computeAverageRank, computeAveragePoints, computeWinRate } from '$lib/utils/wrestler-stats';

	let {
		rankingsData,
		selectedYear,
		locale
	}: { rankingsData: any[]; selectedYear: string | number; locale: Locale } = $props();

	let ChartJS: typeof Chart;
	let pieCanvas = $state<HTMLCanvasElement | null>(null);
	let lineCanvas = $state<HTMLCanvasElement | null>(null);
	let pieChart: Chart | null = null;
	let lineChart: Chart | null = null;

	const averageRank = $derived.by(() => computeAverageRank(rankingsData));
	const averagePoints = $derived.by(() => computeAveragePoints(rankingsData));
	const boutCounts = $derived.by(() => computeBoutCounts(rankingsData));
	const winRate = $derived.by(() => computeWinRate(boutCounts));

	async function ensureChartJS() {
		if (ChartJS) return;
		const chartjs = await import('chart.js');
		ChartJS = chartjs.Chart;
		ChartJS.register(
			chartjs.ArcElement,
			chartjs.BarElement,
			chartjs.CategoryScale,
			chartjs.LinearScale,
			chartjs.PieController,
			chartjs.BarController,
			chartjs.Legend,
			chartjs.Tooltip
		);
	}

	function draw() {
		if (!rankingsData.length || !pieCanvas || !lineCanvas) return;

		const dark = getDark();
		const cWin = dark ? '#7aaa60' : '#4a7a38';
		const cDraw = dark ? '#8a9aad' : '#6b7d94';
		const cLoss = dark ? '#c47070' : '#a04848';
		const textColor = dark ? '#c8c0b4' : '#4a4038';
		const gridColor = dark ? 'rgba(255,255,255,0.06)' : '#e0d8cc';

		const chartDefaults = {
			color: textColor,
			plugins: { legend: { labels: { color: textColor } } },
			scales: {
				x: { ticks: { color: textColor }, grid: { color: gridColor } },
				y: { ticks: { color: textColor }, grid: { color: gridColor } }
			}
		};

		pieChart?.destroy();
		pieChart = new ChartJS(pieCanvas, {
			type: 'pie',
			data: {
				labels: [t(locale, 'wrestler.win'), t(locale, 'wrestler.draw'), t(locale, 'wrestler.loss')],
				datasets: [
					{
						data: [boutCounts.win, boutCounts.draw, boutCounts.loss],
						backgroundColor: [cWin, cDraw, cLoss],
						borderWidth: 0
					}
				]
			},
			options: {
				animation: { animateRotate: false },
				responsive: true,
				plugins: { legend: { labels: { color: textColor } } }
			}
		});

		const grouped: Record<string, { win: number; draw: number; loss: number; total: number }> = {};
		rankingsData.forEach(({ result, expand }: any) => {
			const key =
				selectedYear === 'Alle'
					? expand.place.year
					: (() => {
							const orig = expand.place.originalDate || expand.place.year;
							if (orig?.includes('-')) {
								const [y, m] = orig.split('-');
								return `${m}.${y}`;
							}
							return expand.place.name;
						})();
			if (!grouped[key]) grouped[key] = { win: 0, draw: 0, loss: 0, total: 0 };
			grouped[key].win += (result.match(/\+/g) || []).length;
			grouped[key].draw += (result.match(/-/g) || []).length;
			grouped[key].loss += (result.match(/o/g) || []).length;
			grouped[key].total +=
				(result.match(/\+/g) || []).length +
				(result.match(/-/g) || []).length +
				(result.match(/o/g) || []).length;
		});

		const labels = Object.keys(grouped);
		lineChart?.destroy();
		lineChart = new ChartJS(lineCanvas, {
			type: 'bar',
			data: {
				labels,
				datasets: [
					{
						label: `${t(locale, 'wrestler.win')} %`,
						data: labels.map((k) => (grouped[k].total ? (grouped[k].win / grouped[k].total) * 100 : 0)),
						backgroundColor: cWin
					},
					{
						label: `${t(locale, 'wrestler.draw')} %`,
						data: labels.map((k) =>
							grouped[k].total ? (grouped[k].draw / grouped[k].total) * 100 : 0
						),
						backgroundColor: cDraw
					},
					{
						label: `${t(locale, 'wrestler.loss')} %`,
						data: labels.map((k) => (grouped[k].total ? (grouped[k].loss / grouped[k].total) * 100 : 0)),
						backgroundColor: cLoss
					}
				]
			},
			options: { responsive: true, maintainAspectRatio: false, ...chartDefaults }
		});
	}

	$effect(() => {
		rankingsData;
		selectedYear;
		locale;
		getDark();
		ensureChartJS().then(draw);
	});

	onDestroy(() => {
		pieChart?.destroy();
		lineChart?.destroy();
	});
</script>

{#if rankingsData.length > 0}
	<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
		<div class="card flex flex-col">
			<h3 class="card-title">{t(locale, 'wrestler.overallStats')}</h3>
			<div class="flex flex-wrap items-start justify-between gap-x-4 gap-y-2 mb-2">
				<div class="flex flex-wrap gap-2">
					<span class="chip-win">✓ {boutCounts.win} {t(locale, 'wrestler.win')}</span>
					<span class="chip-draw">— {boutCounts.draw} {t(locale, 'wrestler.draw')}</span>
					<span class="chip-loss">✗ {boutCounts.loss} {t(locale, 'wrestler.loss')}</span>
				</div>
				<div class="flex gap-6 text-sm">
					<div>
						<p class="text-xs text-outline">{t(locale, 'wrestler.avgRank')}</p>
						<p class="font-semibold">{averageRank}</p>
					</div>
					<div>
						<p class="text-xs text-outline">{t(locale, 'wrestler.avgPoints')}</p>
						<p class="font-semibold">{averagePoints}</p>
					</div>
				</div>
			</div>
			<p class="text-xs text-outline mb-3">{winRate}% {t(locale, 'wrestler.winRateSuffix')}</p>
			<div class="flex-1 flex items-center justify-center min-h-[200px]">
				<div class="w-full max-w-[280px]">
					<canvas bind:this={pieCanvas}></canvas>
				</div>
			</div>
		</div>
		<div class="card flex flex-col">
			<h3 class="card-title">{t(locale, 'wrestler.winLossChartTitle')}</h3>
			<div class="flex-1 min-h-[220px]">
				<canvas bind:this={lineCanvas}></canvas>
			</div>
		</div>
	</div>
{/if}
