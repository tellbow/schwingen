<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { escapeFilterValue } from '$lib/utils/filter';

	let { data } = $props();

	// Filter state
	let filterName = $state('');
	let filterVorname = $state('');
	let filterYear = $state('');
	let filterClub = $state('');
	let filterStatus = $state('');
	let loading = $state(false);

	let debounceTimer: ReturnType<typeof setTimeout> | null = null;

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
		if (filterClub) parts.push(`club.name ~ "${escapeFilterValue(filterClub)}"`);
		if (filterStatus) parts.push(filterStatus);
		return parts.join(' && ');
	}

	function search(resetPage = true) {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(async () => {
			loading = true;
			const filter = buildFilter();
			const pageNum = resetPage ? 1 : data.page;
			const params = new URLSearchParams();
			if (filter) params.set('filter', filter);
			if (pageNum > 1) params.set('page', String(pageNum));
			await goto(`/wrestler?${params.toString()}`, { invalidateAll: true });
			loading = false;
		}, 300);
	}

	function goToPage(p: number) {
		const filter = buildFilter();
		const params = new URLSearchParams($page.url.searchParams);
		params.set('page', String(p));
		if (filter) params.set('filter', filter);
		goto(`/wrestler?${params.toString()}`, { invalidateAll: true });
	}

	const totalPages = $derived(Math.ceil(data.total / data.perPage));
</script>

<svelte:head>
	<title>Schwinger - Tellbow</title>
	<meta name="description" content="Durchsuchen Sie alle aktiven Schweizer Schwinger." />
</svelte:head>

<h1 class="sr-only">Schwinger - Tellbow</h1>

<div class="overflow-x-auto">
	<table class="data-table w-full min-w-[600px]">
		<thead>
			<tr>
				<th>Name</th>
				<th class="hidden md:table-cell">Vorname</th>
				<th>Status</th>
				<th class="hidden md:table-cell">Jahrgang</th>
				<th>Schwingklub</th>
			</tr>
			<tr class="bg-surface-low">
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder="Name suchen"
						bind:value={filterName}
						oninput={() => search()}
					/>
				</th>
				<th class="p-1 hidden md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder="Vorname suchen"
						bind:value={filterVorname}
						oninput={() => search()}
					/>
				</th>
				<th class="p-1">
					<select
						class="filter-input"
						bind:value={filterStatus}
						onchange={() => search()}
					>
						{#each STATUS_OPTIONS as opt}
							<option value={opt.value}>{opt.label}</option>
						{/each}
					</select>
				</th>
				<th class="p-1 hidden md:table-cell">
					<input
						type="text"
						class="filter-input"
						placeholder="Jahrgang"
						bind:value={filterYear}
						oninput={() => search()}
					/>
				</th>
				<th class="p-1">
					<input
						type="text"
						class="filter-input"
						placeholder="Klub suchen"
						bind:value={filterClub}
						oninput={() => search()}
					/>
				</th>
			</tr>
		</thead>
		<tbody>
			{#if loading}
				<tr>
					<td colspan="5" class="text-center py-8">
						<div class="spinner mx-auto"></div>
						<p class="mt-2 text-muted-foreground text-sm">Schwinger werden geladen...</p>
					</td>
				</tr>
			{:else if data.wrestlers.length === 0}
				<tr>
					<td colspan="5" class="text-center py-8 text-muted-foreground">Keine Schwinger gefunden.</td>
				</tr>
			{:else}
				{#each data.wrestlers as w}
					<tr onclick={() => goto(`/wrestler/${w.id}`)} class="cursor-pointer">
						<td class="font-medium">
							<a href="/wrestler/{w.id}" class="hover:underline">
								{w.name}
								<span class="md:hidden text-muted-foreground"> {w.vorname}</span>
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

<!-- Pagination -->
{#if totalPages > 1}
	<div class="flex flex-col items-center gap-1 mt-4 py-3">
		<div class="flex gap-1">
			<button
				class="pagination-btn"
				disabled={data.page <= 1}
				onclick={() => goToPage(data.page - 1)}
			>
				‹
			</button>
			{#each Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
				const half = 2;
				let start = Math.max(1, data.page - half);
				let end = Math.min(totalPages, start + 4);
				start = Math.max(1, end - 4);
				return start + i;
			}) as p}
				<button
					class="pagination-btn {p === data.page ? 'pagination-active' : ''}"
					onclick={() => goToPage(p)}
				>
					{p}
				</button>
			{/each}
			<button
				class="pagination-btn"
				disabled={data.page >= totalPages}
				onclick={() => goToPage(data.page + 1)}
			>
				›
			</button>
		</div>
		<span class="text-sm text-muted-foreground">Seite {data.page} von {totalPages}</span>
	</div>
{/if}
