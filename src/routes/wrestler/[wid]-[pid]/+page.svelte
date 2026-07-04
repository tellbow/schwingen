<script lang="ts">
	import { goto } from '$app/navigation';

	let { data } = $props();
	const wrestler = $derived(data.wrestler);
	const place = $derived(data.place);
	const ranking = $derived(data.ranking);
	const bouts = $derived(data.bouts);
</script>

<svelte:head>
	<title>{wrestler.vorname} {wrestler.name}, {place.name} - Tellbow</title>
</svelte:head>

<div class="max-w-4xl mx-auto space-y-4">
	<div class="card">
		<h1 class="text-xl font-bold">
			<a href="/wrestler/{wrestler.id}" class="hover:text-primary transition-colors">
				{wrestler.vorname} {wrestler.name}
			</a>
			@ {place.name}
		</h1>
		<p class="text-sm text-muted-foreground mt-1">
			{place.year} &nbsp;|&nbsp; {place.location ?? ''}
			{#if place.expand?.placeType?.type}
				&nbsp;|&nbsp; {place.expand.placeType.type}
			{/if}
		</p>

		{#if ranking}
			<div class="flex flex-wrap gap-4 mt-4 text-sm">
				<div>
					<p class="text-xs text-outline">Rang</p>
					<p class="font-semibold">{ranking.rank}{ranking.rank2}</p>
				</div>
				<div>
					<p class="text-xs text-outline">Punkte</p>
					<p class="font-semibold">{ranking.points}</p>
				</div>
				<div>
					<p class="text-xs text-outline">Resultat</p>
					<p class="font-mono">{ranking.result}</p>
				</div>
				<div>
					<p class="text-xs text-outline">SF / Kranz</p>
					<p class="font-semibold">{ranking.final ? '🏁' : ''} {ranking.wreath ? '🏆' : ''}</p>
				</div>
			</div>
		{/if}
	</div>

	<div class="card">
		<h2 class="card-title">Gänge ({bouts.length})</h2>
		{#if bouts.length === 0}
			<p class="text-muted-foreground text-sm">Keine Gänge gefunden.</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full">
					<thead>
						<tr>
							<th>Gang</th>
							<th>Resultat</th>
							<th>Punkte</th>
							<th>Gegner</th>
						</tr>
					</thead>
					<tbody>
						{#each bouts as b}
							<tr
								class="cursor-pointer"
								onclick={() => goto(`/wrestler/${b.expand?.opponent?.id}-${place.id}`)}
							>
								<td>{b.fight_round}</td>
								<td class="font-mono text-xs tracking-wider">
									{#each b.result.split('') as char}
										{#if char === '+'}
											<span class="text-on-tertiary-fixed-variant dark:text-tertiary-fixed font-bold">+</span>
										{:else if char === 'o'}
											<span class="text-on-error-container dark:text-error font-bold">o</span>
										{:else}
											<span class="text-secondary-solid">-</span>
										{/if}
									{/each}
								</td>
								<td>{b.points}</td>
								<td class="font-medium">
									{b.expand?.opponent?.name ?? '-'} {b.expand?.opponent?.vorname ?? ''}
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
