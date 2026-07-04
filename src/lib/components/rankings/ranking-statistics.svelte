<script lang="ts">
	import { goto } from '$app/navigation';
	import { t } from '$lib/i18n/index.svelte';

	let { rankings } = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
	{#each rankings as r}
		<div class="bg-surface-low rounded-xl p-4">
			<div class="flex items-center justify-between gap-2 mb-2">
				<button
					class="font-semibold text-sm text-left hover:text-primary transition-colors"
					onclick={() => goto(`/wrestler/${r.expand?.wrestler?.id}`)}
				>
					{r.rank}{r.rank2}. {r.expand?.wrestler?.name ?? '-'} {r.expand?.wrestler?.vorname ?? ''}
					{r.expand?.wrestler?.expand?.status?.symbol ?? ''}
				</button>
				<span class="text-xs text-outline shrink-0">{r.points} {t('rankings.points')}</span>
			</div>
			{#if r.bouts?.length}
				<div class="overflow-x-auto">
					<table class="data-table w-full">
						<thead>
							<tr>
								<th>{t('bouts.result')}</th>
								<th>{t('bouts.opponent')}</th>
								<th>{t('bouts.points')}</th>
							</tr>
						</thead>
						<tbody>
							{#each r.bouts as b}
								<tr onclick={() => goto(`/wrestler/${b.expand?.opponent?.id}`)}>
									<td class="font-mono text-xs">{b.result}</td>
									<td class="font-medium">
										{b.expand?.opponent?.name ?? '-'} {b.expand?.opponent?.vorname ?? ''}
										{b.expand?.opponent?.expand?.status?.symbol ?? ''}
									</td>
									<td>{b.points}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{:else}
				<p class="text-xs text-outline">{t('common.noResults')}</p>
			{/if}
		</div>
	{/each}
</div>
