<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { initLocale, getLocale } from '$lib/i18n/index.svelte';
	import { initDark } from '$lib/dark-mode.svelte';
	import Header from '$lib/components/Header.svelte';
	import Footer from '$lib/components/Footer.svelte';

	let { children } = $props();

	const locale = $derived(getLocale());
	const canonicalUrl = $derived(`https://schwingen.tellbow.ch${$page.url.pathname}`);

	$effect(() => {
		document.documentElement.lang = locale;
	});

	onMount(() => {
		initLocale();
		initDark();
	});
</script>

<svelte:head>
	<link rel="canonical" href={canonicalUrl} />
	<meta property="og:url" content={canonicalUrl} />
</svelte:head>

<a href="#main-content" class="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-50 focus:px-4 focus:py-2 focus:bg-primary focus:text-white focus:rounded-lg focus:outline-none">
	Zum Inhalt springen
</a>
<div class="min-h-screen flex flex-col bg-background">
	<Header />
	<main id="main-content" class="flex-1 container mx-auto px-3 md:px-6 py-6 max-w-screen-xl">
		{@render children()}
	</main>
	<Footer />
</div>
