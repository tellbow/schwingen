<script lang="ts">
	import Hero from '$lib/components/home/Hero.svelte';
	import StatStrip from '$lib/components/home/StatStrip.svelte';
	import DestinationGrid from '$lib/components/home/DestinationGrid.svelte';

	let { data } = $props();
</script>

<svelte:head>
	<title>Tellbow - Alles rund ums Schwingen</title>
	<meta name="description" content="Entdecken Sie umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern. Verbände, Schwingfeste und detaillierte Analysen." />
	<meta property="og:title" content="Tellbow - Alles rund ums Schwingen" />
	<meta property="og:description" content="Entdecken Sie umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern. Verbände, Schwingfeste und detaillierte Analysen." />
</svelte:head>

<Hero />
<StatStrip />
<DestinationGrid eloTop5={data.eloTop5} eloYear={data.eloYear} />
