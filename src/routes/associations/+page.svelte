<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import type { Chart } from 'chart.js';
	import type {
		IChoroplethControllerDatasetOptions,
		IChoroplethDataPoint
	} from 'chartjs-chart-geo';
	import { getDark } from '$lib/dark-mode.svelte';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';
	import {
		buildAssociationFeatures,
		buildCantonFeatures,
		buildGauverbandFeatures,
		type MapFeature,
		type MergedMapFeature,
		type TopologyFeatureReader
	} from '$lib/utils/associations-map';
	import type { CantonStatsRecord, ClubStatsRecord } from '$lib/types/pocketbase';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

	// $state() required for bind:this in Svelte 5 runes mode
	let mapCanvas = $state<HTMLCanvasElement | null>(null);
	let mapChart: Chart<'choropleth'> | null = null;
	let expandedAssociation = $state<string | null>(null);
	let expandedCanton = $state<string | null>(null);
	let mapMode = $state<'association' | 'canton' | 'gauverband'>('association');

	// Topo canton features, country outline and Bern Gauverband features — populated in onMount
	let cantonFeatures: MapFeature[] = [];
	let countryFeature: MapFeature | null = null;
	let gauverbandFeatures: MapFeature[] = [];

	const mapLabel = $derived(
		mapMode === 'association'
			? t(locale, 'associations.mapLabelAssociation')
			: mapMode === 'gauverband'
				? t(locale, 'associations.mapLabelGauverband')
				: t(locale, 'associations.mapLabelCanton')
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
			goto(localizePath(`/associations/association/${feature.id}`, locale));
		} else {
			goto(localizePath(`/associations/canton/${feature.id}`, locale));
		}
	}

	function toChoroplethPoints(features: MergedMapFeature[]): IChoroplethDataPoint[] {
		return features.map((f) => ({
			feature: f as unknown as IChoroplethDataPoint['feature'],
			value: f.wrestlerActive || 0
		}));
	}

	function updateMap(mode: 'association' | 'canton' | 'gauverband', associationId?: string) {
		if (!mapChart) return;
		mapMode = mode;

		let features: MergedMapFeature[];
		if (mode === 'association') {
			features = buildAssociationFeatures(cantonFeatures, data.associations);
		} else if (mode === 'gauverband') {
			const bksvCantons = data.cantons.filter((c) => c.association === associationId);
			features = buildGauverbandFeatures(
				buildCantonFeatures(cantonFeatures, data.cantons, associationId),
				gauverbandFeatures,
				bksvCantons
			);
		} else {
			features = buildCantonFeatures(cantonFeatures, data.cantons, associationId);
		}

		mapChart.data.labels = features.map((f) => f.properties?.name || '');
		mapChart.data.datasets[0].data = toChoroplethPoints(features);
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

		const association = data.associations.find((a) => a.id === expandedAssociation);
		updateMap(association?.abbreviation === 'BKSV' ? 'gauverband' : 'canton', expandedAssociation);
	}

	// Group cantons by association ID
	const cantonsByAssociation = $derived(
		data.cantons.reduce(
			(acc: Record<string, CantonStatsRecord[]>, c) => {
				const key = c.association || 'other';
				if (!acc[key]) acc[key] = [];
				acc[key].push(c);
				return acc;
			},
			{} as Record<string, CantonStatsRecord[]>
		)
	);

	// Group clubs by canton ID
	const clubsByCanton = $derived(
		data.clubs.reduce(
			(acc: Record<string, ClubStatsRecord[]>, c) => {
				const key = c.canton || 'other';
				if (!acc[key]) acc[key] = [];
				acc[key].push(c);
				return acc;
			},
			{} as Record<string, ClubStatsRecord[]>
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

			countryFeature = (topojson as unknown as TopologyFeatureReader).feature(
				maps,
				maps.objects.country
			).features[0];
			cantonFeatures = (topojson as unknown as TopologyFeatureReader).feature(
				maps,
				maps.objects.cantons
			).features;
			gauverbandFeatures = bernGauverbandGeo.features;

			const features = buildAssociationFeatures(cantonFeatures, data.associations);

			const dark = getDark();

			mapChart = new ChartJS(mapCanvas, {
				type: 'choropleth',
				data: {
					labels: features.map((f) => f.properties?.name || ''),
					datasets: [
						{
							label: t(locale, 'associations.chartDatasetLabel'),
							outline: countryFeature as unknown as IChoroplethControllerDatasetOptions['outline'],
							data: toChoroplethPoints(features)
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
				}
			});
		} catch (e) {
			console.error('Error loading map:', e);
		}
	});
</script>

<svelte:head>
	<title>{t(locale, 'associations.metaTitle')}</title>
	<meta name="description" content={t(locale, 'associations.metaDescription')} />
	<meta property="og:title" content={t(locale, 'associations.metaTitle')} />
	<meta property="og:description" content={t(locale, 'associations.metaDescription')} />
</svelte:head>

<h1 class="sr-only">{t(locale, 'associations.metaTitle')}</h1>

<div class="mx-auto max-w-4xl space-y-4">
	<!-- Map -->
	<div class="card">
		<h2 class="card-title">
			{t(locale, 'associations.activeSchwingerByLabel')}
			{mapLabel}
		</h2>
		<!-- Explicit height required for maintainAspectRatio: false to work -->
		<div style="position: relative; height: 420px; overflow: hidden;">
			<canvas bind:this={mapCanvas}></canvas>
		</div>
	</div>

	<!-- Accordion: Association → Canton → Club -->
	<div class="card">
		<h2 class="card-title">{t(locale, 'associations.accordionTitle')}</h2>
		<div class="space-y-2">
			{#each data.associations as assoc (assoc.id)}
				<div class="rounded-lg border border-border">
					<button
						class="flex w-full items-center justify-between px-4 py-3 text-left font-medium transition-colors hover:bg-surface-low"
						onclick={() => toggleAssociation(assoc.id)}
					>
						<span class="flex flex-col">
							<span>
								<a
									href="/associations/association/{assoc.id}"
									class="mr-2 underline hover:text-primary"
									onclick={(e) => e.stopPropagation()}
								>
									{assoc.abbreviation}
								</a>
								{assoc.name}
							</span>
							<span class="mt-0.5 text-xs font-normal text-muted-foreground">
								{assoc.wrestlerActive}
								{t(locale, 'associations.activeLabel')} &nbsp;·&nbsp; * {assoc.wrestler1Star} &nbsp;·&nbsp;
								** {assoc.wrestler2Star} &nbsp;·&nbsp; *** {assoc.wrestler3Star}
							</span>
						</span>
						<span class="ml-3 shrink-0 text-outline"
							>{expandedAssociation === assoc.id ? '▲' : '▼'}</span
						>
					</button>

					{#if expandedAssociation === assoc.id}
						<div class="space-y-1 px-4 pb-2">
							{#each cantonsByAssociation[assoc.id] || [] as canton (canton.id)}
								<div class="border-l-2 border-outline-variant pl-3">
									<button
										class="flex w-full items-center justify-between py-1 text-left text-sm transition-colors hover:bg-surface-low"
										onclick={() =>
											(expandedCanton = expandedCanton === canton.id ? null : canton.id)}
									>
										<a
											href="/associations/canton/{canton.id}"
											class="underline hover:text-primary"
											onclick={(e) => e.stopPropagation()}
										>
											{canton.name}
										</a>
										<span class="text-xs text-muted-foreground">
											{canton.wrestlerActive}
											{t(locale, 'associations.activeLabel')}
											{expandedCanton === canton.id ? ' ▲' : ' ▼'}
										</span>
									</button>

									{#if expandedCanton === canton.id}
										<div class="space-y-0.5 pl-3">
											{#each clubsByCanton[canton.id] || [] as club (club.id)}
												<div
													class="flex items-center justify-between border-b border-outline-variant/20 py-0.5 text-xs transition-colors hover:bg-surface-container"
												>
													<a
														href="/associations/club/{club.id}"
														class="underline hover:text-primary"
													>
														{club.name}
													</a>
													<span class="text-muted-foreground"
														>{club.wrestlerActive} {t(locale, 'associations.activeLabel')}</span
													>
												</div>
											{/each}
											{#if (clubsByCanton[canton.id] || []).length === 0}
												<p class="py-1 text-xs text-outline">
													{t(locale, 'associations.noClubsFound')}
												</p>
											{/if}
										</div>
									{/if}
								</div>
							{/each}
							{#if (cantonsByAssociation[assoc.id] || []).length === 0}
								<p class="py-1 text-sm text-outline">{t(locale, 'associations.noCantonsFound')}</p>
							{/if}
						</div>
					{/if}
				</div>
			{/each}
		</div>
	</div>
</div>
