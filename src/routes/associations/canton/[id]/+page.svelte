<script lang="ts">
	import { goto } from '$app/navigation';

	let { data } = $props();
</script>

<svelte:head>
	<title>{data.canton?.name ?? 'Kanton'} - Tellbow</title>
	<meta name="description" content="Schwinger, Vereine und Statistiken aus dem Kanton {data.canton?.name ?? ''}." />
	<meta property="og:title" content="{data.canton?.name ?? 'Kanton'} - Tellbow" />
	<meta property="og:description" content="Schwinger, Vereine und Statistiken aus dem Kanton {data.canton?.name ?? ''}." />
</svelte:head>

<div class="max-w-4xl mx-auto">
	{#if data.canton}
		<div class="card mb-4">
			<h1 class="text-xl font-bold">{data.canton.name}</h1>
			<p class="text-sm text-muted-foreground mt-1">
				{data.canton.wrestlerActive} aktiv &nbsp;|&nbsp;
				* {data.canton.wrestler1Star} &nbsp;|&nbsp;
				** {data.canton.wrestler2Star} &nbsp;|&nbsp;
				*** {data.canton.wrestler3Star}
			</p>
		</div>
	{:else}
		<h1 class="text-xl font-bold mb-4">Kanton</h1>
	{/if}

	<div class="card">
		<h2 class="card-title">Schwingklubs</h2>
		{#if data.clubs.length === 0}
			<p class="text-muted-foreground text-sm">Keine Klubs gefunden.</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full text-sm">
					<thead>
						<tr>
							<th>Klub</th>
							<th>Aktiv</th>
							<th class="hidden md:table-cell">*</th>
							<th class="hidden md:table-cell">**</th>
							<th class="hidden md:table-cell">***</th>
						</tr>
					</thead>
					<tbody>
						{#each data.clubs as club}
							<tr class="cursor-pointer" onclick={() => goto(`/associations/club/${club.id}`)}>
								<td class="font-medium underline">{club.name}</td>
								<td>{club.wrestlerActive}</td>
								<td class="hidden md:table-cell">{club.wrestler1Star}</td>
								<td class="hidden md:table-cell">{club.wrestler2Star}</td>
								<td class="hidden md:table-cell">{club.wrestler3Star}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
