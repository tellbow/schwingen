<script lang="ts">
	import type { BoutRecord, WithExpand } from '$lib/types/pocketbase';
	import type { TopOpponent } from '$lib/types/wrestler';
	import { getClientPb } from '$lib/pb';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { wrestlerId, locale }: { wrestlerId: string; locale: Locale } = $props();

	let topOpponents = $state<TopOpponent[]>([]);
	let loadingTopOpponents = $state(false);
	let showTopOpponents = $state(false);

	// This component isn't gated by an #if in the parent, so SvelteKit
	// reuses the same instance when navigating between wrestlers — without
	// this, a previous wrestler's top-opponents list would stay visible
	// (and there'd be no way to re-trigger a reload, since the button that
	// starts loadTopOpponents() is only shown while showTopOpponents is false).
	$effect(() => {
		void wrestlerId;
		showTopOpponents = false;
		topOpponents = [];
	});

	async function loadTopOpponents() {
		loadingTopOpponents = true;
		const pb = getClientPb();
		try {
			const d = await pb.collection('bouts').getFullList<WithExpand<BoutRecord, 'opponent'>>(200, {
				filter: `wrestler.id = "${wrestlerId}" && result = "o"`,
				expand: 'opponent,opponent.status,place',
				sort: '-place.year,-created',
				fields:
					'id,result,points,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.opponent.expand.status.symbol,expand.place.id,expand.place.name,expand.place.year'
			});
			const counts: Record<string, Omit<TopOpponent, 'id'>> = {};
			d.forEach((item) => {
				const opp = item.expand.opponent;
				const sym = opp.expand?.status?.symbol ?? '';
				if (counts[opp.id]) counts[opp.id].count++;
				else counts[opp.id] = { count: 1, name: opp.name, vorname: opp.vorname, symbol: sym };
			});
			topOpponents = Object.entries(counts)
				.sort((a, b) => b[1].count - a[1].count)
				.slice(0, 5)
				.map(([id, v]) => ({ id, ...v }));
		} catch (e) {
			console.error(e);
			topOpponents = [];
		} finally {
			loadingTopOpponents = false;
			showTopOpponents = true;
		}
	}
</script>

<div class="card">
	<h3 class="card-title">{t(locale, 'wrestler.topOpponentsTitle')}</h3>
	{#if !showTopOpponents}
		<button class="btn-primary" onclick={loadTopOpponents} disabled={loadingTopOpponents}>
			{loadingTopOpponents ? t(locale, 'common.loading') : t(locale, 'wrestler.show')}
		</button>
	{:else}
		<ol class="space-y-2.5">
			{#each topOpponents as opp, i (opp.id)}
				<li class="flex items-center gap-3">
					<span class="w-4 shrink-0 text-xs font-bold text-outline">{i + 1}</span>
					<a href="/wrestler/{opp.id}" class="flex-1 text-sm transition-colors hover:text-primary">
						{opp.name}
						{opp.vorname}{opp.symbol}
					</a>
					<span class="text-xs text-outline">{opp.count}×</span>
				</li>
			{/each}
		</ol>
	{/if}
</div>
