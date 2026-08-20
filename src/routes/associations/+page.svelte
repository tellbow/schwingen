<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import type { Chart } from 'chart.js';
	import { getDark } from '$lib/dark-mode.svelte';
	import {
		buildAssociationFeatures,
		buildCantonFeatures,
		buildGauverbandFeatures,
		type MergedMapFeature
	} from '$lib/utils/associations-map';

	let { data } = $props();

	// $state() required for bind:this in Svelte 5 runes mode
	let mapCanvas = $state<HTMLCanvasElement | null>(null);
	let mapChart: Chart | null = null;
	let expandedAssociation = $state<string | null>(null);
	let expandedCanton = $state<string | null>(null);
	let mapMode = $state<'association' | 'canton' | 'gauverband'>('association');

	// Topo canton features, country outline and Bern Gauverband features — populated in onMount
	let cantonFeatures: any[] = [];
	let countryFeature: any = null;
	let gauverbandFeatures: any[] = [];

	const mapLabel = $derived(
		mapMode === 'association' ? 'Teilverband' : mapMode === 'gauverband' ? 'Gauverband' : 'Kanton'
	);

	function handleMapClick(evt: unknown) {
		if (!mapChart) return;
		const elements = mapChart.getElementsAtEventForMode(
			evt as never,
			'nearest',
			{ intersect: true },
			true
		);
		if (elements.length === 0) return;
		const feature = (elements[0].element as unknown as { feature: MergedMapFeature }).feature;
		if (!feature.id) return;
		if (mapMode === 'association') {
			goto(`/associations/association/${feature.id}`);
		} else {
			goto(`/associations/canton/${feature.id}`);
		}
	}

	function updateMap(mode: 'association' | 'canton' | 'gauverband', associationId?: string) {
		if (!mapChart) return;
		mapMode = mode;

		let features: MergedMapFeature[];
		if (mode === 'association') {
			features = buildAssociationFeatures(cantonFeatures, data.associations as any);
		} else if (mode === 'gauverband') {
			const bksvCantons = (data.cantons as any[]).filter(
				(c: any) => c.association === associationId
			);
			features = buildGauverbandFeatures(
				buildCantonFeatures(cantonFeatures, data.cantons as any, associationId),
				gauverbandFeatures,
				bksvCantons
			);
		} else {
			features = buildCantonFeatures(cantonFeatures, data.cantons as any, associationId);
		}

		mapChart.data.labels = features.map((f) => f.properties?.name || '');
		mapChart.data.datasets[0].data = features.map((f) => ({
			feature: f,
			value: f.wrestlerActive || 0
		})) as any;
		mapChart.update();
	}

	function toggleAssociation(assocId: string) {
		const wasExpanded = expandedAssociation === assocId;
		expandedAssociation = wasExpanded ? null : assocId;
		expandedCanton = null;

		if (!expandedAssociation) {
			updateMap('association');
			return;
		}

		const association = data.associations.find((a: any) => a.id === expandedAssociation);
		updateMap(association?.abbreviation === 'BKSV' ? 'gauverband' : 'canton', expandedAssociation);
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
			const [chartjs, chartjsGeo, mapsResponse, gauverbandResponse] = await Promise.all([
				import('chart.js'),
				import('chartjs-chart-geo'),
				fetch('/topo/swiss-maps-modified.json'),
				fetch('/topo/bern-gauverband.json')
			]);
			const ChartJS = chartjs.Chart;
			ChartJS.register(
				...chartjs.registerables,
				chartjsGeo.ChoroplethController,
				chartjsGeo.GeoFeature,
				chartjsGeo.ColorScale,
				chartjsGeo.ProjectionScale
			);
			const topojson = chartjsGeo.topojson;

			const maps = await mapsResponse.json();
			const bernGauverbandGeo = await gauverbandResponse.json();

			countryFeature = (topojson as any).feature(maps, maps.objects.country).features[0];
			cantonFeatures = (topojson as any).feature(maps, maps.objects.cantons).features;
			gauverbandFeatures = bernGauverbandGeo.features;

			const features = buildAssociationFeatures(cantonFeatures, data.associations as any);

			const dark = getDark();

			mapChart = new ChartJS(mapCanvas, {
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
					onClick: handleMapClick,
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
			Aktive Schwinger nach {mapLabel}
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
				<div class="border border-border rounded-lg">
					<button
						class="w-full flex items-center justify-between px-4 py-3 text-left hover:bg-surface-low font-medium transition-colors"
						onclick={() => toggleAssociation(assoc.id)}
					>
						<span class="flex flex-col">
							<span>
								<a
									href="/associations/association/{assoc.id}"
									class="underline hover:text-primary mr-2"
									onclick={(e) => e.stopPropagation()}
								>
									{assoc.abbreviation}
								</a>
								{assoc.name}
							</span>
							<span class="text-xs text-muted-foreground font-normal mt-0.5">
								{assoc.wrestlerActive} aktiv &nbsp;·&nbsp; * {assoc.wrestler1Star} &nbsp;·&nbsp; ** {assoc.wrestler2Star} &nbsp;·&nbsp; *** {assoc.wrestler3Star}
							</span>
						</span>
						<span class="text-outline ml-3 shrink-0">{expandedAssociation === assoc.id ? '▲' : '▼'}</span>
					</button>

					{#if expandedAssociation === assoc.id}
						<div class="px-4 pb-2 space-y-1">
							{#each cantonsByAssociation[assoc.id] || [] as canton}
								<div class="border-l-2 border-outline-variant pl-3">
									<button
										class="w-full flex justify-between items-center py-1 text-left text-sm hover:bg-surface-low transition-colors"
										onclick={() => expandedCanton = expandedCanton === canton.id ? null : canton.id}
									>
										<a
											href="/associations/canton/{canton.id}"
											class="underline hover:text-primary"
											onclick={(e) => e.stopPropagation()}
										>
											{canton.name}
										</a>
										<span class="text-xs text-muted-foreground">
											{canton.wrestlerActive} aktiv
											{expandedCanton === canton.id ? ' ▲' : ' ▼'}
										</span>
									</button>

									{#if expandedCanton === canton.id}
										<div class="pl-3 space-y-0.5">
											{#each clubsByCanton[canton.id] || [] as club}
												<div class="flex justify-between items-center py-0.5 text-xs border-b border-outline-variant/20 hover:bg-surface-container transition-colors">
													<a href="/associations/club/{club.id}" class="underline hover:text-primary">
														{club.name}
													</a>
													<span class="text-muted-foreground">{club.wrestlerActive} aktiv</span>
												</div>
											{/each}
											{#if (clubsByCanton[canton.id] || []).length === 0}
												<p class="text-xs text-outline py-1">Keine Klubs gefunden.</p>
											{/if}
										</div>
									{/if}
								</div>
							{/each}
							{#if (cantonsByAssociation[assoc.id] || []).length === 0}
								<p class="text-sm text-outline py-1">Keine Kantone gefunden.</p>
							{/if}
						</div>
					{/if}
				</div>
			{/each}
		</div>
	</div>
</div>
