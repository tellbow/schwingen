<script lang="ts">
	import { buildSearchParams } from '$lib/utils/search-params';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { WRESTLER_STATUS_OPTIONS } from '$lib/utils/filter';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';
	import Pagination from '$lib/components/pagination.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

	// Filter state
	let filterName = $state('');
	let filterVorname = $state('');
	let filterYear = $state('');
	let filterClub = $state('');
	let filterStatus = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	function buildParams(pageNum: number): URLSearchParams {
		return buildSearchParams(
			{
				name: filterName,
				vorname: filterVorname,
				year: filterYear,
				club: filterClub,
				status: filterStatus
			},
			pageNum
		);
	}

	function search(resetPage = true) {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			const pageNum = resetPage ? 1 : data.page;
			await goto(localizePath(`/wrestler?${buildParams(pageNum).toString()}`, locale), {
				invalidateAll: true,
				keepFocus: true
			});
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		goto(localizePath(`/wrestler?${buildParams(p).toString()}`, locale), { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>{t(locale, 'wrestler.metaTitle')}</title>
	<meta name="description" content={t(locale, 'wrestler.metaDescription')} />
	<meta property="og:title" content={t(locale, 'wrestler.metaTitle')} />
	<meta property="og:description" content={t(locale, 'wrestler.metaDescription')} />
</svelte:head>

<h1 class="sr-only">{t(locale, 'wrestler.metaTitle')}</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full min-w-[600px]">
		<thead>
			<tr>
				<th>{t(locale, 'wrestler.name')}</th>
				<th class="hidden md:table-cell">{t(locale, 'wrestler.firstName')}</th>
				<th>{t(locale, 'wrestler.status')}</th>
				<th class="hidden md:table-cell">{t(locale, 'wrestler.yearOfBirth')}</th>
				<th>{t(locale, 'wrestler.club')}</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.searchNamePlaceholder')}
						bind:value={filterName}
						oninput={() => search()}
					/>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.searchVornamePlaceholder')}
						bind:value={filterVorname}
						oninput={() => search()}
					/>
				</th>
				<th class="p-1">
					<select class="filter-input" bind:value={filterStatus} onchange={() => search()}>
						{#each WRESTLER_STATUS_OPTIONS as opt (opt.value)}
							<option value={opt.value}>{t(locale, opt.labelKey)}</option>
						{/each}
					</select>
				</th>
				<th class="hidden p-1 md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.yearOfBirth')}
						bind:value={filterYear}
						oninput={() => search()}
					/>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder={t(locale, 'wrestler.searchClubPlaceholder')}
						bind:value={filterClub}
						oninput={() => search()}
					/>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr>
					<td colspan="5" class="py-8 text-center">
						<div class="spinner mx-auto"></div>
						<p class="mt-2 text-sm text-muted-foreground">{t(locale, 'wrestler.loadingMessage')}</p>
					</td>
				</tr>
			{:else if data.wrestlers.length === 0}
				<tr>
					<td colspan="5" class="py-8 text-center text-muted-foreground"
						>{t(locale, 'wrestler.noResultsFound')}</td
					>
				</tr>
			{:else}
				{#each data.wrestlers as w (w.id)}
					<tr
						onclick={() => goto(localizePath(`/wrestler/${w.id}`, locale))}
						class="cursor-pointer"
					>
						<td class="font-medium">
							<a href="/wrestler/{w.id}" class="hover:underline">
								{w.name}
								<span class="text-muted-foreground md:hidden"> {w.vorname}</span>
							</a>
						</td>
						<td class="hidden md:table-cell">{w.vorname}</td>
						<td>{w.expand?.status?.symbol ?? '-'}</td>
						<td class="hidden md:table-cell">{w.year}</td>
						<td>{w.expand?.club?.name ?? '-'}</td>
					</tr>
				{/each}
			{/if}
		</tbody>
	</table>
</div>

<Pagination page={data.page} {totalPages} onNavigate={goToPage} {locale} />
