<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { escapeFilterValue } from '$lib/utils/filter';

	let { data } = $props();

	let filterName = $state('');
	let filterVorname = $state('');
	let filterYear = $state('');
	let filterStatus = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

	const clubId = $derived($page.params.id);

	const STATUS_OPTIONS = [
		{ label: 'Alle', value: '' },
		{ label: 'Eidgenoss', value: "status.symbol = '***'" },
		{ label: 'Teilverbands- und Bergkranzer', value: "status.symbol = '**'" },
		{ label: 'Kantonal- und Gauverbandskranzer', value: "status.symbol = '*'" },
		{ label: 'Ohne Kranz', value: "status.symbol = ''" }
	];

	function buildFilter(): string {
		const parts: string[] = [];
		if (filterName) parts.push(`name ~ "${escapeFilterValue(filterName)}"`);
		if (filterVorname) parts.push(`vorname ~ "${escapeFilterValue(filterVorname)}"`);
		if (filterYear) parts.push(`year ~ "${escapeFilterValue(filterYear)}"`);
		if (filterStatus) parts.push(filterStatus);
		return parts.join(' && ');
	}

	function search() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			const filter = buildFilter();
			const params = new URLSearchParams();
			if (filter) params.set('filter', filter);
			await goto(`/associations/club/${clubId}?${params.toString()}`, { invalidateAll: true });
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		const filter = buildFilter();
		const params = new URLSearchParams($page.url.searchParams);
		params.set('page', String(p));
		if (filter) params.set('filter', filter);
		goto(`/associations/club/${clubId}?${params.toString()}`, { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>{data.club?.name ?? 'Schwingklub'} - Tellbow</title>
</svelte:head>

<div class="max-w-4xl mx-auto">
	{#if data.club}
		<div class="card mb-4">
			<h1 class="text-xl font-bold">{data.club.name}</h1>
			<p class="text-sm text-muted-foreground mt-1">
				{data.club.wrestlerActive} aktiv &nbsp;|&nbsp;
				* {data.club.wrestler1Star} &nbsp;|&nbsp;
				** {data.club.wrestler2Star} &nbsp;|&nbsp;
				*** {data.club.wrestler3Star}
			</p>
		</div>
	{:else}
		<h1 class="text-xl font-bold mb-4">Schwingklub</h1>
	{/if}

	<div class="overflow-x-auto">
		<table class="data-table w-full">
			<thead>
				<tr>
					<th>Name</th>
					<th class="hidden md:table-cell">Vorname</th>
					<th>Status</th>
					<th class="hidden md:table-cell">Jahrgang</th>
				</tr>
				<tr class="bg-surface-low">
					<th class="p-1">
						<input type="text" class="filter-input" placeholder="Name" bind:value={filterName} oninput={search} />
					</th>
					<th class="p-1 hidden md:table-cell">
						<input type="text" class="filter-input" placeholder="Vorname" bind:value={filterVorname} oninput={search} />
					</th>
					<th class="p-1">
						<select class="filter-input" bind:value={filterStatus} onchange={search}>
							{#each STATUS_OPTIONS as opt}
								<option value={opt.value}>{opt.label}</option>
							{/each}
						</select>
					</th>
					<th class="p-1 hidden md:table-cell">
						<input type="text" class="filter-input" placeholder="Jahrgang" bind:value={filterYear} oninput={search} />
					</th>
				</tr>
			</thead>
			<tbody>
				{#if loading}
					<tr><td colspan="4" class="text-center py-8"><div class="spinner mx-auto"></div></td></tr>
				{:else if data.wrestlers.length === 0}
					<tr><td colspan="4" class="text-center py-8 text-muted-foreground">Keine Schwinger gefunden.</td></tr>
				{:else}
					{#each data.wrestlers as w}
						<tr class="cursor-pointer" onclick={() => goto(`/wrestler/${w.id}`)}>
							<td class="font-medium">
								{w.name}
								<span class="md:hidden text-muted-foreground"> {w.vorname}</span>
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
			<span class="text-sm text-muted-foreground">{data.total} Schwinger, Seite {data.page} von {totalPages}</span>
			<div class="flex gap-1">
				<button class="pagination-btn" disabled={data.page <= 1} onclick={() => goToPage(data.page - 1)}>‹</button>
				{#each Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
					let start = Math.max(1, data.page - 3);
					const end = Math.min(totalPages, start + 6);
					start = Math.max(1, end - 6);
					return start + i;
				}) as p}
					<button class="pagination-btn {p === data.page ? 'pagination-active' : ''}" onclick={() => goToPage(p)}>{p}</button>
				{/each}
				<button class="pagination-btn" disabled={data.page >= totalPages} onclick={() => goToPage(data.page + 1)}>›</button>
			</div>
		</div>
	{/if}
</div>
