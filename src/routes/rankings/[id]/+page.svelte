<script lang="ts">
	import { goto } from '$app/navigation';

	let { data } = $props();
	const place = $derived(data.place);
	const rankings = $derived(data.rankings);
</script>

<svelte:head>
	<title>{place.name} {place.year} - Rangliste - Tellbow</title>
</svelte:head>

<div class="max-w-4xl mx-auto">
	<div class="card mb-4">
		<h1 class="text-xl font-bold">{place.name}</h1>
		<p class="text-sm text-gray-600 mt-1">
			{place.year} &nbsp;|&nbsp; {place.location ?? ''}
			{#if place.expand?.placeType?.type}
				&nbsp;|&nbsp; {place.expand.placeType.type}
			{/if}
		</p>
	</div>

	<div class="overflow-x-auto">
		<table class="data-table w-full">
			<thead>
				<tr>
					<th>Rang</th>
					<th>Punkte</th>
					<th>Name</th>
					<th class="hidden md:table-cell">Vorname</th>
					<th>Resultat</th>
					<th class="hidden md:table-cell">SF</th>
					<th class="hidden md:table-cell">Kranz</th>
					<th class="hidden md:table-cell">Status</th>
				</tr>
			</thead>
			<tbody>
				{#if rankings.length === 0}
					<tr><td colspan="8" class="text-center py-8 text-gray-500">Keine Einträge gefunden.</td></tr>
				{/if}
				{#each rankings as r}
					<tr class="cursor-pointer" onclick={() => goto(`/wrestler/${r.expand?.wrestler?.id}`)}>
						<td>{r.rank}{r.rank2}</td>
						<td>{r.points}</td>
						<td class="font-medium">
							{r.expand?.wrestler?.name ?? '-'}
							<span class="md:hidden text-gray-500 text-xs"> {r.expand?.wrestler?.vorname ?? ''}</span>
						</td>
						<td class="hidden md:table-cell">{r.expand?.wrestler?.vorname ?? '-'}</td>
						<td class="font-mono text-xs">{r.result}</td>
						<td class="hidden md:table-cell">{r.final ? '🏁' : ''}</td>
						<td class="hidden md:table-cell">{r.wreath ? '🏆' : ''}</td>
						<td class="hidden md:table-cell text-xs">{r.status ?? ''}</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>
</div>
