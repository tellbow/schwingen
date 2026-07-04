<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { goto } from '$app/navigation';
	import { getClientPb } from '$lib/pb';
	import {
		Chart,
		ArcElement, BarElement, CategoryScale, LinearScale,
		PieController, BarController,
		Legend, Tooltip
	} from 'chart.js';
	import { getDark } from '$lib/dark-mode.svelte';

	Chart.register(ArcElement, BarElement, CategoryScale, LinearScale, PieController, BarController, Legend, Tooltip);

	let { data } = $props();
	const wrestler = $derived(data.wrestler);

	let selectedYear = $state<string | number>('Alle');
	let rankingsData = $state<any[]>([]);
	let opponentsData = $state<any[]>([]);
	let selectedOpponent = $state('');
	let boutsData = $state<any[]>([]);
	let topOpponents = $state<any[]>([]);
	let eloData = $state<any>(null);
	let wreath1 = $state(0);
	let wreath2 = $state(0);
	let wreath3 = $state(0);

	let loadingRankings = $state(true);
	let loadingOpponents = $state(true);
	let loadingTopOpponents = $state(false);
	let loadingBouts = $state(false);
	let showTopOpponents = $state(false);

	let pieCanvas = $state<HTMLCanvasElement | null>(null);
	let lineCanvas = $state<HTMLCanvasElement | null>(null);
	let pieChart: Chart | null = null;
	let lineChart: Chart | null = null;

	const YEARS = [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 'Alle'];

	const averageRank = $derived(() => {
		const filtered = rankingsData.filter((r) => r.status !== 'Unfall');
		if (filtered.length < 5) return '-';
		const total = filtered.reduce((s: number, r: any) => s + (parseInt(r.rank.replace(/\D/g, '')) || 0), 0);
		return (total / filtered.length).toFixed(2);
	});

	const averagePoints = $derived(() => {
		const filtered = rankingsData.filter(
			(r) =>
				r.status !== 'Unfall' &&
				!r.expand?.place?.expand?.placeType?.type?.includes('idgenössisch')
		);
		if (filtered.length < 5) return '-';
		const total = filtered.reduce((s: number, r: any) => s + (parseFloat(r.points) || 0), 0);
		return (total / filtered.length).toFixed(2);
	});

	const boutCounts = $derived(
		rankingsData.reduce(
			(acc: any, { result }: any) => ({
				win: acc.win + (result.match(/\+/g) || []).length,
				draw: acc.draw + (result.match(/-/g) || []).length,
				loss: acc.loss + (result.match(/o/g) || []).length
			}),
			{ win: 0, draw: 0, loss: 0 }
		)
	);

	const winRate = $derived(() => {
		const total = boutCounts.win + boutCounts.draw + boutCounts.loss;
		return total > 0 ? Math.round((boutCounts.win / total) * 100) : 0;
	});

	async function loadElo() {
		const pb = getClientPb();
		const years = YEARS.filter((y) => y !== 'Alle').map(Number).sort((a, b) => b - a);
		if (selectedYear === 'Alle') {
			for (const y of years) {
				try {
					const res = await pb.collection(`elo${y}`).getList(1, 1, {
						filter: `wrestler.id="${wrestler.id}"`,
						skipTotal: true,
						fields: 'id,rating'
					});
					if (res.items.length > 0) {
						eloData = res.items[0];
						return;
					}
				} catch {
					// collection may not exist for this year
				}
			}
			eloData = { rating: '-' };
		} else {
			try {
				const res = await pb.collection(`elo${selectedYear}`).getList(1, 1, {
					filter: `wrestler.id="${wrestler.id}"`,
					skipTotal: true,
					fields: 'id,rating'
				});
				eloData = res.items.length > 0 ? res.items[0] : { rating: '-' };
			} catch {
				eloData = { rating: '-' };
			}
		}
	}

	async function loadRankings() {
		loadingRankings = true;
		const pb = getClientPb();
		const filter =
			selectedYear === 'Alle'
				? `wrestler.id = "${wrestler.id}"`
				: `wrestler.id = "${wrestler.id}" && place.year ~ "${selectedYear}"`;

		try {
			const d = await pb.collection('rankings').getFullList(200, {
				filter,
				expand: 'place,place.placeType',
				sort: '-place.year,-created',
				fields:
					'id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.place.name,expand.place.year,expand.place.expand.placeType.type'
			});

			wreath1 = 0;
			wreath2 = 0;
			wreath3 = 0;
			d.forEach((item: any) => {
				if (item.wreath) {
					const t = item.expand?.place?.expand?.placeType?.type;
					if (t === 'Gauverband' || t === 'Kantonal') wreath1++;
					else if (t === 'Teilverband' || t === 'Berg') wreath2++;
					else if (t === 'Eidgenössisch') wreath3++;
				}
				if (item.expand?.place) {
					item.expand.place.originalDate = item.expand.place.year;
					item.expand.place.year = item.expand.place.year.split('-')[0];
				}
			});
			rankingsData = d;
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
			const d = await pb.collection('bouts').getFullList(200, {
				filter,
				expand: 'opponent',
				sort: 'opponent.name,-created',
				fields: 'id,expand.opponent.id,expand.opponent.name,expand.opponent.vorname'
			});
			const map = new Map<string, any>();
			d.forEach((item: any) => {
				const opp = item.expand.opponent;
				if (!map.has(opp.id)) map.set(opp.id, opp);
			});
			opponentsData = Array.from(map.values());
		} catch (e) {
			console.error(e);
			opponentsData = [];
		} finally {
			loadingOpponents = false;
		}
	}

	async function loadTopOpponents() {
		loadingTopOpponents = true;
		const pb = getClientPb();
		try {
			const d = await pb.collection('bouts').getFullList(200, {
				filter: `wrestler.id = "${wrestler.id}" && result = "o"`,
				expand: 'opponent,opponent.status,place',
				sort: '-place.year,-created',
				fields:
					'id,result,points,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.opponent.expand.status.symbol,expand.place.id,expand.place.name,expand.place.year'
			});
			const counts: Record<string, any> = {};
			d.forEach((item: any) => {
				const opp = item.expand.opponent;
				const sym = opp.expand?.status?.symbol ?? '';
				if (counts[opp.id]) counts[opp.id].count++;
				else counts[opp.id] = { count: 1, name: opp.name, vorname: opp.vorname, symbol: sym };
			});
			topOpponents = Object.entries(counts)
				.sort((a, b) => b[1].count - a[1].count)
				.slice(0, 5)
				.map(([id, v]) => ({ id, ...v }));
		} catch (e) {
			console.error(e);
			topOpponents = [];
		} finally {
			loadingTopOpponents = false;
			showTopOpponents = true;
		}
	}

	async function loadBouts() {
		if (!selectedOpponent) return;
		loadingBouts = true;
		const pb = getClientPb();
		try {
			const d = await pb.collection('bouts').getFullList(200, {
				filter: `wrestler.id = "${wrestler.id}" && opponent.id = "${selectedOpponent}"`,
				expand: 'place',
				sort: '-place.year,-created',
				fields: 'id,result,points,expand.place.id,expand.place.name,expand.place.year'
			});
			d.forEach((item: any) => {
				item.expand.place.year = item.expand.place.year.split('-')[0];
			});
			boutsData = d;
		} catch (e) {
			console.error(e);
			boutsData = [];
		} finally {
			loadingBouts = false;
		}
	}

	function updateCharts() {
		if (!rankingsData.length) return;

		const dark = document.documentElement.classList.contains('dark');
		const cWin  = dark ? '#7aaa60' : '#4a7a38';
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

		if (pieCanvas) {
			pieChart?.destroy();
			pieChart = new Chart(pieCanvas, {
				type: 'pie',
				data: {
					labels: ['Sieg', 'Gestellt', 'Niederlage'],
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
		}

		if (lineCanvas) {
			const grouped: Record<string, { win: number; draw: number; loss: number; total: number }> =
				{};
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
			lineChart = new Chart(lineCanvas, {
				type: 'bar',
				data: {
					labels,
					datasets: [
						{
							label: 'Sieg %',
							data: labels.map((k) =>
								grouped[k].total ? (grouped[k].win / grouped[k].total) * 100 : 0
							),
							backgroundColor: cWin
						},
						{
							label: 'Gestellt %',
							data: labels.map((k) =>
								grouped[k].total ? (grouped[k].draw / grouped[k].total) * 100 : 0
							),
							backgroundColor: cDraw
						},
						{
							label: 'Niederlage %',
							data: labels.map((k) =>
								grouped[k].total ? (grouped[k].loss / grouped[k].total) * 100 : 0
							),
							backgroundColor: cLoss
						}
					]
				},
				options: { responsive: true, maintainAspectRatio: false, ...chartDefaults }
			});
		}
	}

	async function onYearChange() {
		await Promise.all([loadRankings(), loadOpponents(), loadElo()]);
		updateCharts();
	}

	onMount(async () => {
		await Promise.all([loadElo(), loadRankings(), loadOpponents()]);
		updateCharts();
	});

	onDestroy(() => {
		pieChart?.destroy();
		lineChart?.destroy();
	});
</script>

<svelte:head>
	<title>{wrestler.vorname} {wrestler.name} - Tellbow</title>
	<meta name="description" content="Profil und Statistiken von {wrestler.vorname} {wrestler.name}." />
</svelte:head>

<h1 class="sr-only">Schwinger Profil</h1>

<!-- Hero -->
<div class="bg-surface-low rounded-2xl px-6 py-8 md:px-10 md:py-10 mb-4">
	<p class="text-xs font-semibold uppercase tracking-widest text-outline mb-2">Schwinger Profil</p>
	<h2 class="text-4xl md:text-5xl font-extrabold tracking-tight text-foreground leading-none">
		{wrestler.vorname} {wrestler.name}
	</h2>

	<div class="flex flex-wrap items-center gap-x-2 gap-y-1 mt-3 text-sm text-outline">
		{#if wrestler.expand?.club}
			<a href="/associations/club/{wrestler.expand.club.id}" class="hover:text-foreground transition-colors">
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
			<a href={wrestler.expand.metadata.website} target="_blank" rel="noopener" class="hover:text-foreground transition-colors underline underline-offset-2">Website</a>
		{/if}
	</div>

	<div class="grid grid-cols-2 md:grid-cols-4 gap-3 mt-6">
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">ELO-Rating</p>
			<p class="text-2xl font-bold tracking-tight">{eloData?.rating ?? '…'}</p>
		</div>
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">Jahrgang</p>
			<p class="text-2xl font-bold tracking-tight">{wrestler.year}</p>
		</div>
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">Kränze</p>
			<p class="text-base font-bold tracking-tight mt-1">{wreath1}* · {wreath2}** · {wreath3}***</p>
		</div>
		<div class="bg-surface-lowest rounded-xl p-4">
			<p class="text-xs text-outline mb-1">Status</p>
			{#if wrestler.expand?.status}
				<p class="text-sm font-semibold mt-1">{wrestler.expand.status.status}</p>
				<p class="text-xs text-outline">{wrestler.category ? 'aktiv' : 'inaktiv'}</p>
			{:else}
				<p class="text-sm font-semibold mt-1">—</p>
			{/if}
		</div>
	</div>
</div>

<!-- Stats + Charts -->
{#if !loadingRankings && rankingsData.length > 0}
	<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
		<div class="card flex flex-col">
			<h3 class="card-title">Gesamtstatistik</h3>
			<div class="flex flex-wrap items-start justify-between gap-x-4 gap-y-2 mb-2">
				<div class="flex flex-wrap gap-2">
					<span class="chip-win">✓ {boutCounts.win} Sieg</span>
					<span class="chip-draw">— {boutCounts.draw} Gestellt</span>
					<span class="chip-loss">✗ {boutCounts.loss} Niederlage</span>
				</div>
				<div class="flex gap-6 text-sm">
					<div>
						<p class="text-xs text-outline">Ø Rang</p>
						<p class="font-semibold">{averageRank()}</p>
					</div>
					<div>
						<p class="text-xs text-outline">Ø Punkte</p>
						<p class="font-semibold">{averagePoints()}</p>
					</div>
				</div>
			</div>
			<p class="text-xs text-outline mb-3">{winRate()}% Siegquote</p>
			<div class="flex-1 flex items-center justify-center min-h-[200px]">
				<div class="w-full max-w-[280px]">
					<canvas bind:this={pieCanvas}></canvas>
				</div>
			</div>
		</div>
		<div class="card flex flex-col">
			<h3 class="card-title">Sieg / Gestellt / Niederlage</h3>
			<div class="flex-1 min-h-[220px]">
				<canvas bind:this={lineCanvas}></canvas>
			</div>
		</div>
	</div>
{/if}

<!-- Resultate -->
<div class="card mb-4">
	<div class="flex items-center justify-between mb-4 flex-wrap gap-2">
		<h3 class="card-title mb-0">Resultate</h3>
		<div class="flex items-center gap-2">
			<label class="text-xs text-outline font-medium" for="year-select">Jahr</label>
			<select
				id="year-select"
				class="select-input"
				bind:value={selectedYear}
				onchange={onYearChange}
			>
				{#each YEARS as y}
					<option value={y}>{y}</option>
				{/each}
			</select>
		</div>
	</div>

	{#if loadingRankings}
		<div class="text-center py-10"><div class="spinner mx-auto"></div></div>
	{:else if rankingsData.length === 0}
		<p class="text-outline text-sm py-4">Keine Resultate vorhanden.</p>
	{:else}
		<div class="overflow-x-auto">
			<table class="data-table w-full">
				<thead>
					<tr>
						<th>Schwingfest</th>
						<th class="hidden md:table-cell">Jahr</th>
						<th>Rang</th>
						<th>Pkt</th>
						<th>Resultat</th>
						<th class="hidden md:table-cell">SF</th>
						<th class="hidden md:table-cell">Kranz</th>
					</tr>
				</thead>
				<tbody>
					{#each rankingsData as r}
						<tr onclick={() => goto(`/wrestler/${wrestler.id}-${r.expand?.place?.id}`)}>
							<td class="font-medium">{r.expand?.place?.name ?? '-'}</td>
							<td class="hidden md:table-cell text-outline">{r.expand?.place?.year ?? '-'}</td>
							<td class="font-semibold">{r.rank}{r.rank2}</td>
							<td>{r.points}</td>
							<td class="font-mono text-xs tracking-wider">
								{#each r.result.split('') as char}
									{#if char === '+'}
										<span class="text-on-tertiary-fixed-variant dark:text-tertiary-fixed font-bold">+</span>
									{:else if char === 'o'}
										<span class="text-on-error-container dark:text-error font-bold">o</span>
									{:else}
										<span class="text-secondary-solid">-</span>
									{/if}
								{/each}
							</td>
							<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
							<td class="hidden md:table-cell">
								{r.wreath ? '🏆' : ''}
								{r.status === 'Unfall' ? '🩹' : ''}
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</div>

<!-- 1 vs 1 -->
<div class="card mb-4">
	<h3 class="card-title">1 vs. 1</h3>
	<div class="flex gap-2 items-center flex-wrap">
		<select
			class="select-input"
			bind:value={selectedOpponent}
			disabled={loadingOpponents}
		>
			<option value="">Gegner wählen…</option>
			{#each opponentsData as opp}
				<option value={opp.id}>{opp.name} {opp.vorname}</option>
			{/each}
		</select>
		<button
			class="btn-primary"
			onclick={loadBouts}
			disabled={!selectedOpponent || loadingBouts}
		>
			{loadingBouts ? 'Laden...' : 'Suchen'}
		</button>
	</div>
	{#if boutsData.length > 0}
		<div class="overflow-x-auto mt-4">
			<table class="data-table w-full">
				<thead>
					<tr>
						<th>Schwingfest</th>
						<th>Jahr</th>
						<th>Pkt</th>
						<th>Resultat</th>
					</tr>
				</thead>
				<tbody>
					{#each boutsData as b}
						<tr onclick={() => goto(`/wrestler/${wrestler.id}-${b.expand.place.id}`)}>
							<td class="font-medium">{b.expand.place.name}</td>
							<td class="text-outline">{b.expand.place.year}</td>
							<td>{b.points}</td>
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
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</div>

<!-- Top Opponents -->
<div class="card">
	<h3 class="card-title">Top 5 Gegner (verloren gegen)</h3>
	{#if !showTopOpponents}
		<button class="btn-primary" onclick={loadTopOpponents} disabled={loadingTopOpponents}>
			{loadingTopOpponents ? 'Laden...' : 'Anzeigen'}
		</button>
	{:else}
		<ol class="space-y-2.5">
			{#each topOpponents as opp, i}
				<li class="flex items-center gap-3">
					<span class="text-xs font-bold text-outline w-4 shrink-0">{i + 1}</span>
					<button
						class="text-sm hover:text-primary transition-colors text-left flex-1"
						onclick={() => goto(`/wrestler/${opp.id}`)}
					>
						{opp.name} {opp.vorname}{opp.symbol}
					</button>
					<span class="text-xs text-outline">{opp.count}×</span>
				</li>
			{/each}
		</ol>
	{/if}
</div>
