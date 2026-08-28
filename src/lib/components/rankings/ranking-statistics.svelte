<script lang="ts">
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { rankings, locale }: { rankings: any[]; locale: Locale } = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
	{#each rankings as r}
		<div class="bg-surface-low rounded-xl p-4">
			<div class="flex items-center justify-between gap-2 mb-2">
				<a
					href="/wrestler/{r.expand?.wrestler?.id}"
					class="font-semibold text-sm text-left hover:text-primary transition-colors"
				>
					{r.rank}{r.rank2}. {r.expand?.wrestler?.name ?? '-'} {r.expand?.wrestler?.vorname ?? ''}
					{r.expand?.wrestler?.expand?.status?.symbol ?? ''}
				</a>
				<span class="text-xs text-outline shrink-0">{r.points} {t(locale, 'rankings.points')}</span>
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
							{#each r.bouts as b}
								<tr>
									<td class="font-mono text-xs">{b.result}</td>
									<td class="font-medium">
										<a href="/wrestler/{b.expand?.opponent?.id}" class="hover:underline">
											{b.expand?.opponent?.name ?? '-'} {b.expand?.opponent?.vorname ?? ''}
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
