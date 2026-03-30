<script lang="ts">
	import { onMount } from 'svelte';
	import { Chart, registerables } from 'chart.js';
	import {
		ChoroplethController,
		GeoFeature,
		ColorScale,
		ProjectionScale,
		topojson
	} from 'chartjs-chart-geo';
	import { getDark } from '$lib/dark-mode.svelte';

	Chart.register(...registerables, ChoroplethController, GeoFeature, ColorScale, ProjectionScale);

	let { data } = $props();

	// $state() required for bind:this in Svelte 5 runes mode
	let mapCanvas = $state<HTMLCanvasElement | null>(null);
	let mapChart: Chart | null = null;
	let expandedAssociation = $state<string | null>(null);
	let expandedCanton = $state<string | null>(null);

	// Topo canton features and country outline — populated in onMount
	let cantonFeatures: any[] = [];
	let countryFeature: any = null;

	// Association abbreviation → list of topo canton names
	const associationTopoCantons: Record<string, string[]> = {
		BKSV: ['Bern'],
		ISV: ['Luzern', 'Nidwalden', 'Obwalden', 'Schwyz', 'Tessin', 'Uri', 'Zug'],
		NOSV: [
			'Appenzell Ausserrhoden',
			'Appenzell Innerrhoden',
			'Glarus',
			'Graubünden',
			'Schaffhausen',
			'St. Gallen',
			'Thurgau',
			'Zürich'
		],
		NWSV: ['Aargau', 'Basel-Stadt', 'Baselland', 'Solothurn'],
		SWSV: ['Fribourgeoise', 'Genevoise', 'Jura', 'Neuchâteloise', 'Valaisanne', 'Vaudoise']
	};

	/** Build features coloured by association (all cantons in same association share the association's total) */
	function buildAssociationFeatures() {
		const byName: Record<string, any> = {};
		for (const f of cantonFeatures) {
			const name = f.properties?.name;
			if (name) byName[name] = { ...f, wrestlerActive: 0 };
		}
		for (const assoc of data.associations) {
			const topoNames = associationTopoCantons[assoc.abbreviation] ?? [];
			for (const name of topoNames) {
				if (byName[name]) byName[name].wrestlerActive = assoc.wrestlerActive;
			}
		}
		return Object.values(byName);
	}

	/** Build features coloured per canton (Bern = sum of 6 sub-regions, etc.) */
	function buildCantonFeatures() {
		const byName: Record<string, any> = {};
		for (const f of cantonFeatures) {
			const name = f.properties?.name;
			if (name) byName[name] = { ...f, wrestlerActive: 0 };
		}
		for (const canton of data.cantons) {
			const name = canton.name;
			switch (name) {
				case 'Berner-Jura':
				case 'Emmental':
				case 'Mittelland':
				case 'Oberaargau':
				case 'Oberland':
				case 'Seeland':
					if (byName.Bern) byName.Bern.wrestlerActive += canton.wrestlerActive;
					break;
				case 'Ob- und Nidwalden':
					if (byName.Obwalden) byName.Obwalden.wrestlerActive += canton.wrestlerActive;
					if (byName.Nidwalden) byName.Nidwalden.wrestlerActive += canton.wrestlerActive;
					break;
				case 'Appenzell':
					if (byName['Appenzell Ausserrhoden'])
						byName['Appenzell Ausserrhoden'].wrestlerActive += canton.wrestlerActive;
					if (byName['Appenzell Innerrhoden'])
						byName['Appenzell Innerrhoden'].wrestlerActive += canton.wrestlerActive;
					break;
				default:
					if (byName[name]) byName[name].wrestlerActive += canton.wrestlerActive;
			}
		}
		return Object.values(byName);
	}

	function updateMap(mode: 'association' | 'canton') {
		if (!mapChart) return;
		const features = mode === 'association' ? buildAssociationFeatures() : buildCantonFeatures();
		mapChart.data.labels = features.map((f: any) => f.properties?.name || '');
		mapChart.data.datasets[0].data = features.map((f: any) => ({
			feature: f,
			value: f.wrestlerActive || 0
		}));
		mapChart.update();
	}

	function toggleAssociation(assocId: string) {
		const wasExpanded = expandedAssociation === assocId;
		expandedAssociation = wasExpanded ? null : assocId;
		expandedCanton = null;
		updateMap(expandedAssociation ? 'canton' : 'association');
	}

	// Group cantons by association ID
	const cantonsByAssociation = $derived(
		data.cantons.reduce(
			(acc: Record<string, any[]>, c: any) => {
				const key = c.association || 'other';
				if (!acc[key]) acc[key] = [];
				acc[key].push(c);
				return acc;
			},
			{} as Record<string, any[]>
		)
	);

	// Group clubs by canton ID
	const clubsByCanton = $derived(
		data.clubs.reduce(
			(acc: Record<string, any[]>, c: any) => {
				const key = c.canton || 'other';
				if (!acc[key]) acc[key] = [];
				acc[key].push(c);
				return acc;
			},
			{} as Record<string, any[]>
		)
	);

	onMount(async () => {
		if (!mapCanvas) return;
		try {
			const response = await fetch('/topo/swiss-maps-modified.json');
			const maps = await response.json();

			countryFeature = (topojson as any).feature(maps, maps.objects.country).features[0];
			cantonFeatures = (topojson as any).feature(maps, maps.objects.cantons).features;

			const features = buildAssociationFeatures();

			const dark = getDark();

			mapChart = new Chart(mapCanvas, {
				type: 'choropleth',
				data: {
					labels: features.map((f: any) => f.properties?.name || ''),
					datasets: [
						{
							label: 'Aktive Schwinger',
							outline: countryFeature,
							data: features.map((f: any) => ({
								feature: f,
								value: f.wrestlerActive || 0
							}))
						}
					]
				},
				options: {
					responsive: true,
					maintainAspectRatio: false,
					showOutline: true,
					showGraticule: false,
					plugins: {
						legend: { display: false }
					},
					scales: {
						projection: {
							axis: 'x',
							projection: 'mercator'
						},
						color: {
							axis: 'x',
							quantize: 5,
							interpolate: dark
								? (t: number) => `hsl(${30 + t * 15}, ${40 + t * 50}%, ${10 + t * 45}%)`
								: (t: number) => `hsl(${35 - t * 10}, ${20 + t * 70}%, ${90 - t * 55}%)`,
							legend: {
								position: 'bottom-right',
								align: 'bottom'
							}
						}
					}
				} as any
			});
		} catch (e) {
			console.error('Error loading map:', e);
		}
	});
</script>

<svelte:head>
	<title>Verbände - Tellbow</title>
	<meta name="description" content="Übersicht über alle Teilverbände, Kantone und Vereine im Schweizer Schwingen." />
</svelte:head>

<h1 class="sr-only">Verbände - Tellbow</h1>

<div class="max-w-4xl mx-auto space-y-4">
	<!-- Map -->
	<div class="card">
		<h2 class="card-title">
			Aktive Schwinger nach {expandedAssociation ? 'Kanton' : 'Teilverband'}
		</h2>
		<!-- Explicit height required for maintainAspectRatio: false to work -->
		<div style="position: relative; height: 420px; overflow: hidden;">
			<canvas bind:this={mapCanvas}></canvas>
		</div>
	</div>

	<!-- Accordion: Association → Canton → Club -->
	<div class="card">
		<h2 class="card-title">Teilverbände, Kantone und Klubs</h2>
		<div class="space-y-2">
			{#each data.associations as assoc}
				<div class="border border-gray-200 rounded">
					<button
						class="w-full flex items-center justify-between px-4 py-3 text-left hover:bg-gray-50 font-medium"
						onclick={() => toggleAssociation(assoc.id)}
					>
						<span class="flex flex-col">
							<span>
								<a
									href="/associations/association/{assoc.id}"
									class="underline hover:text-zinc-600 mr-2"
									onclick={(e) => e.stopPropagation()}
								>
									{assoc.abbreviation}
								</a>
								{assoc.name}
							</span>
							<span class="text-xs text-gray-500 font-normal mt-0.5">
								{assoc.wrestlerActive} aktiv &nbsp;·&nbsp; * {assoc.wrestler1Star} &nbsp;·&nbsp; ** {assoc.wrestler2Star} &nbsp;·&nbsp; *** {assoc.wrestler3Star}
							</span>
						</span>
						<span class="text-gray-400 ml-3 shrink-0">{expandedAssociation === assoc.id ? '▲' : '▼'}</span>
					</button>

					{#if expandedAssociation === assoc.id}
						<div class="px-4 pb-2 space-y-1">
							{#each cantonsByAssociation[assoc.id] || [] as canton}
								<div class="border-l-2 border-gray-300 pl-3">
									<button
										class="w-full flex justify-between items-center py-1 text-left text-sm hover:bg-gray-50"
										onclick={() => expandedCanton = expandedCanton === canton.id ? null : canton.id}
									>
										<a
											href="/associations/canton/{canton.id}"
											class="underline hover:text-zinc-600"
											onclick={(e) => e.stopPropagation()}
										>
											{canton.name}
										</a>
										<span class="text-xs text-gray-500">
											{canton.wrestlerActive} aktiv
											{expandedCanton === canton.id ? ' ▲' : ' ▼'}
										</span>
									</button>

									{#if expandedCanton === canton.id}
										<div class="pl-3 space-y-0.5">
											{#each clubsByCanton[canton.id] || [] as club}
												<div class="flex justify-between items-center py-0.5 text-xs border-b border-gray-100 hover:bg-gray-50">
													<a href="/associations/club/{club.id}" class="underline hover:text-zinc-600">
														{club.name}
													</a>
													<span class="text-gray-500">{club.wrestlerActive} aktiv</span>
												</div>
											{/each}
											{#if (clubsByCanton[canton.id] || []).length === 0}
												<p class="text-xs text-gray-400 py-1">Keine Klubs gefunden.</p>
											{/if}
										</div>
									{/if}
								</div>
							{/each}
							{#if (cantonsByAssociation[assoc.id] || []).length === 0}
								<p class="text-sm text-gray-400 py-1">Keine Kantone gefunden.</p>
							{/if}
						</div>
					{/if}
				</div>
			{/each}
		</div>
	</div>
</div>
