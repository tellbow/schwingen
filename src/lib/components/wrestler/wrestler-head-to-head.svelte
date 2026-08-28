<script lang="ts">
	import { getClientPb } from '$lib/pb';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { yearOnly } from '$lib/utils/format';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let {
		wrestlerId,
		opponentsData,
		loadingOpponents,
		locale
	}: { wrestlerId: string; opponentsData: any[]; loadingOpponents: boolean; locale: Locale } =
		$props();

	let selectedOpponent = $state('');
	let boutsData = $state<any[]>([]);
	let loadingBouts = $state(false);

	// This component isn't gated by an #if in the parent, so SvelteKit
	// reuses the same instance when navigating between wrestlers — reset
	// the previous wrestler's selection and results when that happens.
	$effect(() => {
		wrestlerId;
		selectedOpponent = '';
		boutsData = [];
	});

	async function loadBouts() {
		if (!selectedOpponent) return;
		loadingBouts = true;
		const pb = getClientPb();
		try {
			const d = await pb.collection('bouts').getFullList(200, {
				filter: `wrestler.id = "${wrestlerId}" && opponent.id = "${escapeFilterValue(selectedOpponent)}"`,
				expand: 'place',
				sort: '-place.year,-created',
				fields: 'id,result,points,expand.place.id,expand.place.name,expand.place.year'
			});
			d.forEach((item: any) => {
				item.expand.place.year = yearOnly(item.expand.place.year);
			});
			boutsData = d;
		} catch (e) {
			console.error(e);
			boutsData = [];
		} finally {
			loadingBouts = false;
		}
	}
</script>

<div class="card mb-4">
	<h3 class="card-title">{t(locale, 'wrestler.oneVsOne')}</h3>
	<div class="flex gap-2 items-center flex-wrap">
		<select class="select-input" bind:value={selectedOpponent} disabled={loadingOpponents}>
			<option value="">{t(locale, 'wrestler.selectOpponent')}</option>
			{#each opponentsData as opp}
				<option value={opp.id}>{opp.name} {opp.vorname}</option>
			{/each}
		</select>
		<button class="btn-primary" onclick={loadBouts} disabled={!selectedOpponent || loadingBouts}>
			{loadingBouts ? t(locale, 'common.loading') : t(locale, 'wrestler.searchButton')}
		</button>
	</div>
	{#if boutsData.length > 0}
		<div class="overflow-x-auto mt-4">
			<table class="data-table w-full">
				<thead>
					<tr>
						<th>{t(locale, 'rankings.colSchwingfest')}</th>
						<th>{t(locale, 'rankings.colYear')}</th>
						<th>{t(locale, 'wrestler.colPoints')}</th>
						<th>{t(locale, 'rankings.result')}</th>
					</tr>
				</thead>
				<tbody>
					{#each boutsData as b}
						<tr>
							<td class="font-medium">
								<a
									href="/wrestler/{wrestlerId}-{b.expand.place.id}"
									class="hover:underline"
								>
									{b.expand.place.name}
								</a>
							</td>
							<td class="text-outline">{b.expand.place.year}</td>
							<td>{b.points}</td>
							<td class="font-mono text-xs tracking-wider">
								{#each b.result.split('') as char}
									{#if char === '+'}
										<span class="text-on-tertiary-fixed-variant dark:text-tertiary-fixed font-bold"
											>+</span
										>
									{:else if char === 'o'}
										<span class="text-on-error-container dark:text-error font-bold">o</span>
									{:else}
										<span class="text-secondary-solid">-</span>
									{/if}
								{/each}
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</div>
