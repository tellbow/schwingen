<script lang="ts">
	import { page } from '$app/stores';
	import { t, type Locale } from '$lib/i18n/index.svelte';
	import Hero from '$lib/components/home/Hero.svelte';
	import DestinationGrid from '$lib/components/home/DestinationGrid.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);
</script>

<svelte:head>
	<title>{t(locale, 'home.metaTitle')}</title>
	<meta name="description" content={t(locale, 'home.metaDescription')} />
	<meta property="og:title" content={t(locale, 'home.metaTitle')} />
	<meta property="og:description" content={t(locale, 'home.metaDescription')} />
</svelte:head>

<Hero />
<DestinationGrid eloTop5={data.eloTop5} eloYear={data.eloYear} />
