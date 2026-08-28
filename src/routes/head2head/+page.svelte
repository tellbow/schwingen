<script lang="ts">
	import { goto } from '$app/navigation';
	import { getClientPb } from '$lib/pb';
	import { escapeFilterValue } from '$lib/utils/filter';

	let searchTerm1 = $state('');
	let searchTerm2 = $state('');
	let results1 = $state<any[]>([]);
	let results2 = $state<any[]>([]);
	let selected1 = $state<any>(null);
	let selected2 = $state<any>(null);
	let searching1 = $state(false);
	let searching2 = $state(false);

	let timer1: ReturnType<typeof setTimeout> | null = null;
	let timer2: ReturnType<typeof setTimeout> | null = null;

	async function searchWrestlers(term: string, num: 1 | 2) {
		if (!term || term.length < 2) {
			if (num === 1) results1 = [];
			else results2 = [];
			return;
		}
		const pb = getClientPb();
		if (num === 1) searching1 = true;
		else searching2 = true;

		try {
			const escaped = escapeFilterValue(term);
			const d = await pb.collection('wrestler').getList(1, 10, {
				filter: `name ~ "${escaped}" || vorname ~ "${escaped}"`,
				sort: '-status.symbol,name',
				fields: 'id,name,vorname'
			});
			if (num === 1) results1 = d.items;
			else results2 = d.items;
		} catch (e) {
			console.error(e);
		} finally {
			if (num === 1) searching1 = false;
			else searching2 = false;
		}
	}

	function debounceSearch(term: string, num: 1 | 2) {
		if (num === 1) {
			if (timer1) clearTimeout(timer1);
			timer1 = setTimeout(() => searchWrestlers(term, 1), 300);
		} else {
			if (timer2) clearTimeout(timer2);
			timer2 = setTimeout(() => searchWrestlers(term, 2), 300);
		}
	}

	function select(wrestler: any, num: 1 | 2) {
		if (num === 1) {
			selected1 = wrestler;
			searchTerm1 = `${wrestler.name} ${wrestler.vorname}`;
			results1 = [];
		} else {
			selected2 = wrestler;
			searchTerm2 = `${wrestler.name} ${wrestler.vorname}`;
			results2 = [];
		}
	}

	function compare() {
		if (selected1 && selected2 && selected1.id !== selected2.id) {
			goto(`/head2head/${selected1.id}-${selected2.id}`);
		}
	}

	const canCompare = $derived(selected1 && selected2 && selected1.id !== selected2.id);
</script>

<svelte:head>
	<title>Direktvergleich - Tellbow</title>
	<meta name="description" content="Vergleichen Sie zwei Schweizer Schwinger direkt miteinander." />
	<meta property="og:title" content="Direktvergleich - Tellbow" />
	<meta property="og:description" content="Vergleichen Sie zwei Schweizer Schwinger direkt miteinander." />
</svelte:head>

<div class="max-w-2xl mx-auto">
	<h1 class="text-xl font-bold mb-4">Direktvergleich</h1>

	<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
		<!-- Wrestler 1 -->
		<div class="card">
			<h2 class="font-semibold mb-2">Schwinger 1</h2>
			<div class="relative">
				<input
					type="text"
					class="filter-input"
					placeholder="Name oder Vorname eingeben…"
					bind:value={searchTerm1}
					oninput={() => debounceSearch(searchTerm1, 1)}
				/>
				{#if searching1}
					<div class="absolute right-2 top-2"><div class="spinner w-4 h-4"></div></div>
				{/if}
				{#if results1.length > 0}
					<ul class="absolute z-10 w-full bg-surface-lowest border border-border rounded-lg mt-1 max-h-48 overflow-y-auto">
						{#each results1 as w}
							<li>
								<button
									class="w-full text-left px-3 py-2 text-lg md:text-sm hover:bg-surface-container transition-colors cursor-pointer"
									onclick={() => select(w, 1)}
								>
									{w.name} {w.vorname}
								</button>
							</li>
						{/each}
					</ul>
				{/if}
			</div>
			{#if selected1}
				<p class="text-xs text-tertiary mt-1">Ausgewählt: {selected1.name} {selected1.vorname}</p>
			{/if}
		</div>

		<!-- Wrestler 2 -->
		<div class="card">
			<h2 class="font-semibold mb-2">Schwinger 2</h2>
			<div class="relative">
				<input
					type="text"
					class="filter-input"
					placeholder="Name oder Vorname eingeben…"
					bind:value={searchTerm2}
					oninput={() => debounceSearch(searchTerm2, 2)}
				/>
				{#if searching2}
					<div class="absolute right-2 top-2"><div class="spinner w-4 h-4"></div></div>
				{/if}
				{#if results2.length > 0}
					<ul class="absolute z-10 w-full bg-surface-lowest border border-border rounded-lg mt-1 max-h-48 overflow-y-auto">
						{#each results2 as w}
							<li>
								<button
									class="w-full text-left px-3 py-2 text-lg md:text-sm hover:bg-surface-container transition-colors cursor-pointer"
									onclick={() => select(w, 2)}
								>
									{w.name} {w.vorname}
								</button>
							</li>
						{/each}
					</ul>
				{/if}
			</div>
			{#if selected2}
				<p class="text-xs text-tertiary mt-1">Ausgewählt: {selected2.name} {selected2.vorname}</p>
			{/if}
		</div>
	</div>

	{#if selected1 && selected2 && selected1.id === selected2.id}
		<p class="mt-4 text-error text-sm">Bitte zwei verschiedene Schwinger auswählen.</p>
	{/if}

	<div class="mt-6">
		<button
			class="btn-primary px-6 py-2"
			onclick={compare}
			disabled={!canCompare}
		>
			Vergleichen
		</button>
	</div>
</div>
