<script lang="ts">
	import type { RankingWithBouts } from '$lib/types/pocketbase';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { rankings, locale }: { rankings: RankingWithBouts[]; locale: Locale } = $props();
</script>

<div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-3">
	{#each rankings as r (r.id)}
		<div class="rounded-xl bg-surface-low p-4">
			<div class="mb-2 flex items-center justify-between gap-2">
				<a
					href="/wrestler/{r.expand?.wrestler?.id}"
					class="text-left text-sm font-semibold transition-colors hover:text-primary"
				>
					{r.rank}{r.rank2}. {r.expand?.wrestler?.name ?? '-'}
					{r.expand?.wrestler?.vorname ?? ''}
					{r.expand?.wrestler?.expand?.status?.symbol ?? ''}
				</a>
				<span class="shrink-0 text-xs text-outline">{r.points} {t(locale, 'rankings.points')}</span>
			</div>
			{#if r.bouts?.length}
				<div class="overflow-x-auto">
					<table class="data-table w-full">
						<thead>
							<tr>
								<th>{t(locale, 'bouts.result')}</th>
								<th>{t(locale, 'bouts.opponent')}</th>
								<th>{t(locale, 'bouts.points')}</th>
							</tr>
						</thead>
						<tbody>
							{#each r.bouts as b (b.id)}
								<tr>
									<td class="font-mono text-xs">{b.result}</td>
									<td class="font-medium">
										<a href="/wrestler/{b.expand?.opponent?.id}" class="hover:underline">
											{b.expand?.opponent?.name ?? '-'}
											{b.expand?.opponent?.vorname ?? ''}
											{b.expand?.opponent?.expand?.status?.symbol ?? ''}
										</a>
									</td>
									<td>{b.points}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{:else}
				<p class="text-xs text-outline">{t(locale, 'common.noResults')}</p>
			{/if}
		</div>
	{/each}
</div>
