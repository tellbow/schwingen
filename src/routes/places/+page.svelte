<script lang="ts">
	import { buildSearchParams } from '$lib/utils/search-params';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { formatDate } from '$lib/utils/format';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';
	import Pagination from '$lib/components/pagination.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

	let filterNumber = $state('');
	let filterName = $state('');
	let filterLocation = $state('');
	let filterYear = $state('');
	let filterType = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const YEARS = [
		'',
		'2015',
		'2016',
		'2017',
		'2018',
		'2019',
		'2020',
		'2021',
		'2022',
		'2023',
		'2024',
		'2025',
		'2026'
	];
	const PLACE_TYPES = [
		{ value: '', labelKey: 'common.all' },
		{ value: 'Sonstige', labelKey: 'places.typeSonstige' },
		{ value: 'Gauverband', labelKey: 'places.typeGauverband' },
		{ value: 'Regional', labelKey: 'places.typeRegional' },
		{ value: 'mit eidgenössischem Charakter', labelKey: 'places.typeMitEidgenoessischemCharakter' },
		{ value: 'Eidgenössisch', labelKey: 'places.typeEidgenoessisch' },
		{ value: 'Teilverband', labelKey: 'places.typeTeilverband' },
		{ value: 'Kantonal', labelKey: 'places.typeKantonal' },
		{ value: 'Berg', labelKey: 'places.typeBerg' }
	];

	function buildParams(pageNum: number): URLSearchParams {
		return buildSearchParams(
			{
				number: filterNumber,
				name: filterName,
				location: filterLocation,
				year: filterYear,
				type: filterType
			},
			pageNum
		);
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			await goto(localizePath(`/places?${buildParams(1).toString()}`, locale), {
				invalidateAll: true,
				keepFocus: true
			});
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		goto(localizePath(`/places?${buildParams(p).toString()}`, locale), { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>{t(locale, 'places.metaTitle')}</title>
	<meta name="description" content={t(locale, 'places.metaDescription')} />
	<meta property="og:title" content={t(locale, 'places.metaTitle')} />
	<meta property="og:description" content={t(locale, 'places.metaDescription')} />
</svelte:head>

<h1 class="sr-only">{t(locale, 'places.metaTitle')}</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full">
		<thead>
			<tr>
				<th class="hidden md:table-cell">{t(locale, 'places.number')}</th>
				<th>{t(locale, 'places.name')}</th>
				<th class="hidden md:table-cell">{t(locale, 'places.location')}</th>
				<th>{t(locale, 'places.date')}</th>
				<th class="hidden md:table-cell">{t(locale, 'places.type')}</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'places.number')}
						bind:value={filterNumber}
						oninput={search}
					/>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'places.name')}
						bind:value={filterName}
						oninput={search}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'places.location')}
						bind:value={filterLocation}
						oninput={search}
					/>
				</th>
				<th class="p-1">
					<select class="filter-input" bind:value={filterYear} onchange={search}>
						{#each YEARS as y (y)}
							<option value={y}>{y || t(locale, 'common.all')}</option>
						{/each}
					</select>
				</th>
				<th class="hidden p-1 md:table-cell">
					<select class="filter-input" bind:value={filterType} onchange={search}>
						{#each PLACE_TYPES as opt (opt.value)}
							<option value={opt.value}>{t(locale, opt.labelKey)}</option>
						{/each}
					</select>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr><td colspan="5" class="py-8 text-center"><div class="spinner mx-auto"></div></td></tr>
			{:else if data.places.length === 0}
				<tr
					><td colspan="5" class="py-8 text-center text-muted-foreground"
						>{t(locale, 'places.noResultsFound')}</td
					></tr
				>
			{:else}
				{#each data.places as p (p.id)}
					<tr
						class="cursor-pointer"
						onclick={() => goto(localizePath(`/rankings/${p.id}`, locale))}
					>
						<td class="hidden md:table-cell">{p.number}</td>
						<td class="font-medium">
							<a href="/rankings/{p.id}" class="hover:underline">
								{p.name}
							</a>
							<span class="block text-xs text-muted-foreground md:hidden"
								>{p.expand?.placeType?.type ?? ''}</span
							>
						</td>
						<td class="hidden md:table-cell">{p.location ?? '-'}</td>
						<td class="whitespace-nowrap">{formatDate(p.year, locale)}</td>
						<td class="hidden text-xs md:table-cell">{p.expand?.placeType?.type ?? '-'}</td>
					</tr>
				{/each}
			{/if}
		</tbody>
	</table>
</div>

<Pagination page={data.page} {totalPages} onNavigate={goToPage} {locale} />
