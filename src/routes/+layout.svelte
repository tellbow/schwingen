<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { t, localizePath, LOCALES, type Locale } from '$lib/i18n/index.svelte';
	import { initDark } from '$lib/dark-mode.svelte';
	import Header from '$lib/components/Header.svelte';
	import Footer from '$lib/components/Footer.svelte';

	let { data, children } = $props();

	const locale = $derived(data.locale as Locale);
	const canonicalUrl = $derived(`https://schwingen.tellbow.ch${$page.url.pathname}`);
	const alternateUrls = $derived(
		LOCALES.map((loc) => ({
			locale: loc,
			href: `https://schwingen.tellbow.ch${localizePath($page.url.pathname, loc)}`
		}))
	);

	$effect(() => {
		document.documentElement.lang = locale;
	});

	// Content pages link internally using plain, locale-agnostic paths
	// (e.g. `/wrestler/123`). While browsing in French, those need to become
	// `/fr/...` so navigation stays in French. Rewriting the <a> href here,
	// in the capture phase, runs *before* SvelteKit's own (bubble-phase)
	// click handler reads it — so SvelteKit just sees a normal link to the
	// right URL from the start. The locale switcher is marked
	// data-sveltekit-reload, so it's excluded here and always does a real
	// navigation instead.
	//
	// Programmatic goto() calls (search/pagination/row clicks) don't
	// originate from an <a> click, so they don't go through this handler —
	// every such call site localizes its own target with localizePath()
	// instead. (A beforeNavigate-based catch-all for those was tried and
	// removed: it couldn't forward the original goto() options like
	// keepFocus/invalidateAll, since `beforeNavigate`'s nav object doesn't
	// expose them, so search inputs lost focus on every keystroke in French.)
	function localizeLinkHref(event: MouseEvent) {
		if (locale !== 'fr') return;
		const anchor = (event.target as HTMLElement)?.closest?.('a[href]') as HTMLAnchorElement | null;
		if (!anchor || anchor.hasAttribute('data-sveltekit-reload')) return;

		const url = new URL(anchor.href);
		if (url.origin !== location.origin || url.pathname.startsWith('/fr')) return;

		anchor.href = `/fr${url.pathname === '/' ? '' : url.pathname}${url.search}${url.hash}`;
	}

	onMount(() => {
		initDark();
	});
</script>

<svelte:window onclickcapture={localizeLinkHref} />

<svelte:head>
	<link rel="canonical" href={canonicalUrl} />
	<meta property="og:url" content={canonicalUrl} />
	{#each alternateUrls as alt}
		<link rel="alternate" hreflang={alt.locale} href={alt.href} />
	{/each}
	<link rel="alternate" hreflang="x-default" href={`https://schwingen.tellbow.ch${localizePath($page.url.pathname, 'de')}`} />
</svelte:head>

<a href="#main-content" class="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-50 focus:px-4 focus:py-2 focus:bg-primary focus:text-white focus:rounded-lg focus:outline-none">
	{t(locale, 'common.skipToContent')}
</a>
<div class="min-h-screen flex flex-col bg-background">
	<Header />
	<main id="main-content" class="flex-1 container mx-auto px-3 md:px-6 py-6 max-w-screen-xl">
		{@render children()}
	</main>
	<Footer />
</div>
