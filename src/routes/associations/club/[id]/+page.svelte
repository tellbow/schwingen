<script lang="ts">
	import { buildSearchParams } from '$lib/utils/search-params';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { WRESTLER_STATUS_OPTIONS } from '$lib/utils/filter';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);

	let filterName = $state('');
	let filterVorname = $state('');
	let filterYear = $state('');
	let filterStatus = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const clubId = $derived($page.params.id);

	function buildParams(pageNum: number): URLSearchParams {
		return buildSearchParams(
			{
				name: filterName,
				vorname: filterVorname,
				year: filterYear,
				status: filterStatus
			},
			pageNum
		);
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			await goto(
				localizePath(`/associations/club/${clubId}?${buildParams(1).toString()}`, locale),
				{
					invalidateAll: true
				}
			);
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		goto(localizePath(`/associations/club/${clubId}?${buildParams(p).toString()}`, locale), {
			invalidateAll: true
		});
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>{data.club?.name ?? t(locale, 'associations.clubFallbackTitle')} - Tellbow</title>
	<meta
		name="description"
		content="{t(locale, 'associations.clubMetaDescriptionPrefix')} {data.club?.name ?? ''}."
	/>
	<meta
		property="og:title"
		content="{data.club?.name ?? t(locale, 'associations.clubFallbackTitle')} - Tellbow"
	/>
	<meta
		property="og:description"
		content="{t(locale, 'associations.clubMetaDescriptionPrefix')} {data.club?.name ?? ''}."
	/>
</svelte:head>

<div class="mx-auto max-w-4xl">
	{#if data.club}
		<div class="card mb-4">
			<h1 class="text-xl font-bold">{data.club.name}</h1>
			<p class="mt-1 text-sm text-muted-foreground">
				{data.club.wrestlerActive}
				{t(locale, 'associations.activeLabel')} &nbsp;|&nbsp; * {data.club.wrestler1Star} &nbsp;|&nbsp;
				** {data.club.wrestler2Star} &nbsp;|&nbsp; *** {data.club.wrestler3Star}
			</p>
		</div>
	{:else}
		<h1 class="mb-4 text-xl font-bold">{t(locale, 'associations.clubFallbackTitle')}</h1>
	{/if}

	<div class="overflow-x-auto">
		<table class="data-table w-full">
			<thead>
				<tr>
					<th>{t(locale, 'wrestler.name')}</th>
					<th class="hidden md:table-cell">{t(locale, 'wrestler.firstName')}</th>
					<th>{t(locale, 'wrestler.status')}</th>
					<th class="hidden md:table-cell">{t(locale, 'wrestler.yearOfBirth')}</th>
				</tr>
				<tr class="bg-surface-low">
					<th class="p-1">
						<input
							type="text"
							class="filter-input"
							placeholder={t(locale, 'wrestler.name')}
							bind:value={filterName}
							oninput={search}
						/>
					</th>
					<th class="hidden p-1 md:table-cell">
						<input
							type="text"
							class="filter-input"
							placeholder={t(locale, 'wrestler.firstName')}
							bind:value={filterVorname}
							oninput={search}
						/>
					</th>
					<th class="p-1">
						<select class="filter-input" bind:value={filterStatus} onchange={search}>
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
							oninput={search}
						/>
					</th>
				</tr>
			</thead>
			<tbody>
				{#if loading}
					<tr><td colspan="4" class="py-8 text-center"><div class="spinner mx-auto"></div></td></tr>
				{:else if data.wrestlers.length === 0}
					<tr
						><td colspan="4" class="py-8 text-center text-muted-foreground"
							>{t(locale, 'wrestler.noResultsFound')}</td
						></tr
					>
				{:else}
					{#each data.wrestlers as w (w.id)}
						<tr>
							<td class="font-medium">
								<a href="/wrestler/{w.id}" class="hover:underline">
									{w.name}
									<span class="text-muted-foreground md:hidden"> {w.vorname}</span>
								</a>
							</td>
							<td class="hidden md:table-cell">{w.vorname}</td>
							<td>{w.expand?.status?.symbol ?? '-'}</td>
							<td class="hidden md:table-cell">{w.year}</td>
						</tr>
					{/each}
				{/if}
			</tbody>
		</table>
	</div>

	{#if totalPages > 1}
		<div class="pagination mt-4">
			<span class="text-sm text-muted-foreground"
				>{data.total}
				{t(locale, 'wrestler.title')}, {t(locale, 'common.page')}
				{data.page}
				{t(locale, 'common.of')}
				{totalPages}</span
			>
			<div class="flex gap-1">
				<button
					class="pagination-btn"
					disabled={data.page <= 1}
					onclick={() => goToPage(data.page - 1)}>‹</button
				>
				{#each Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
					let start = Math.max(1, data.page - 3);
					const end = Math.min(totalPages, start + 6);
					start = Math.max(1, end - 6);
					return start + i;
				}) as p (p)}
					<button
						class="pagination-btn {p === data.page ? 'pagination-active' : ''}"
						onclick={() => goToPage(p)}>{p}</button
					>
				{/each}
				<button
					class="pagination-btn"
					disabled={data.page >= totalPages}
					onclick={() => goToPage(data.page + 1)}>›</button
				>
			</div>
		</div>
	{/if}
</div>
