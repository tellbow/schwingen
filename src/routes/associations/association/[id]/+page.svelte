<script lang="ts">
	import { goto } from '$app/navigation';

	let { data } = $props();
</script>

<svelte:head>
	<title>{data.association?.name ?? 'Schwingerverband'} - Tellbow</title>
</svelte:head>

<div class="max-w-4xl mx-auto">
	{#if data.association}
		<div class="card mb-4">
			<h1 class="text-xl font-bold">{data.association.name} ({data.association.abbreviation})</h1>
			<p class="text-sm text-gray-600 mt-1">
				{data.association.wrestlerActive} aktiv &nbsp;|&nbsp;
				* {data.association.wrestler1Star} &nbsp;|&nbsp;
				** {data.association.wrestler2Star} &nbsp;|&nbsp;
				*** {data.association.wrestler3Star}
			</p>
		</div>
	{:else}
		<h1 class="text-xl font-bold mb-4">Schwingerverband</h1>
	{/if}

	<div class="card">
		<h2 class="card-title">Kantone / Gauverbände</h2>
		{#if data.cantons.length === 0}
			<p class="text-gray-500 text-sm">Keine Kantone gefunden.</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full text-sm">
					<thead>
						<tr>
							<th>Kanton / Gauverband</th>
							<th>Aktiv</th>
							<th class="hidden md:table-cell">*</th>
							<th class="hidden md:table-cell">**</th>
							<th class="hidden md:table-cell">***</th>
						</tr>
					</thead>
					<tbody>
						{#each data.cantons as canton}
							<tr class="cursor-pointer" onclick={() => goto(`/associations/canton/${canton.id}`)}>
								<td class="font-medium underline">{canton.name}</td>
								<td>{canton.wrestlerActive}</td>
								<td class="hidden md:table-cell">{canton.wrestler1Star}</td>
								<td class="hidden md:table-cell">{canton.wrestler2Star}</td>
								<td class="hidden md:table-cell">{canton.wrestler3Star}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
