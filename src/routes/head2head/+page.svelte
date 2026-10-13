<script lang="ts">
	import type { WrestlerRecord } from '$lib/types/pocketbase';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { getClientPb } from '$lib/pb';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';

	const locale = $derived($page.data.locale as Locale);

	let searchTerm1 = $state('');
	let searchTerm2 = $state('');
	let results1 = $state<WrestlerRecord[]>([]);
	let results2 = $state<WrestlerRecord[]>([]);
	let selected1 = $state<WrestlerRecord | null>(null);
	let selected2 = $state<WrestlerRecord | null>(null);
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
			const d = await pb.collection('wrestler').getList<WrestlerRecord>(1, 10, {
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

	function select(wrestler: WrestlerRecord, num: 1 | 2) {
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
			goto(localizePath(`/head2head/${selected1.id}-${selected2.id}`, locale));
		}
	}

	const canCompare = $derived(selected1 && selected2 && selected1.id !== selected2.id);
</script>

<svelte:head>
	<title>{t(locale, 'head2head.title')} - Tellbow</title>
	<meta name="description" content={t(locale, 'head2head.metaDescription')} />
	<meta property="og:title" content="{t(locale, 'head2head.title')} - Tellbow" />
	<meta property="og:description" content={t(locale, 'head2head.metaDescription')} />
</svelte:head>

<div class="mx-auto max-w-2xl">
	<h1 class="mb-4 text-xl font-bold">{t(locale, 'head2head.title')}</h1>

	<div class="grid grid-cols-1 gap-6 md:grid-cols-2">
		<!-- Wrestler 1 -->
		<div class="card">
			<h2 class="mb-2 font-semibold">{t(locale, 'head2head.wrestler1')}</h2>
			<div class="relative">
				<input
					type="text"
					class="filter-input"
					placeholder={t(locale, 'head2head.searchPlaceholder')}
					bind:value={searchTerm1}
					oninput={() => debounceSearch(searchTerm1, 1)}
				/>
				{#if searching1}
					<div class="absolute top-2 right-2"><div class="spinner h-4 w-4"></div></div>
				{/if}
				{#if results1.length > 0}
					<ul
						class="absolute z-10 mt-1 max-h-48 w-full overflow-y-auto rounded-lg border border-border bg-surface-lowest"
					>
						{#each results1 as w (w.id)}
							<li>
								<button
									class="w-full cursor-pointer px-3 py-2 text-left text-lg transition-colors hover:bg-surface-container md:text-sm"
									onclick={() => select(w, 1)}
								>
									{w.name}
									{w.vorname}
								</button>
							</li>
						{/each}
					</ul>
				{/if}
			</div>
			{#if selected1}
				<p class="mt-1 text-xs text-tertiary">
					{t(locale, 'head2head.selectedLabel')}
					{selected1.name}
					{selected1.vorname}
				</p>
			{/if}
		</div>

		<!-- Wrestler 2 -->
		<div class="card">
			<h2 class="mb-2 font-semibold">{t(locale, 'head2head.wrestler2')}</h2>
			<div class="relative">
				<input
					type="text"
					class="filter-input"
					placeholder={t(locale, 'head2head.searchPlaceholder')}
					bind:value={searchTerm2}
					oninput={() => debounceSearch(searchTerm2, 2)}
				/>
				{#if searching2}
					<div class="absolute top-2 right-2"><div class="spinner h-4 w-4"></div></div>
				{/if}
				{#if results2.length > 0}
					<ul
						class="absolute z-10 mt-1 max-h-48 w-full overflow-y-auto rounded-lg border border-border bg-surface-lowest"
					>
						{#each results2 as w (w.id)}
							<li>
								<button
									class="w-full cursor-pointer px-3 py-2 text-left text-lg transition-colors hover:bg-surface-container md:text-sm"
									onclick={() => select(w, 2)}
								>
									{w.name}
									{w.vorname}
								</button>
							</li>
						{/each}
					</ul>
				{/if}
			</div>
			{#if selected2}
				<p class="mt-1 text-xs text-tertiary">
					{t(locale, 'head2head.selectedLabel')}
					{selected2.name}
					{selected2.vorname}
				</p>
			{/if}
		</div>
	</div>

	{#if selected1 && selected2 && selected1.id === selected2.id}
		<p class="mt-4 text-sm text-error">{t(locale, 'head2head.selectDifferentWarning')}</p>
	{/if}

	<div class="mt-6">
		<button class="btn-primary px-6 py-2" onclick={compare} disabled={!canCompare}>
			{t(locale, 'head2head.compareButton')}
		</button>
	</div>
</div>
