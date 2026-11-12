<script lang="ts">
	import { page } from '$app/state';
	import { t, type Locale } from '#lib/i18n/index.svelte.js';
	import { PRIVACY_SECTIONS } from '#lib/i18n/privacy.js';

	const locale = $derived(page.data.locale as Locale);
</script>

<svelte:head>
	<title>{t(locale, 'privacy.title')} - Tellbow</title>
	<meta name="description" content={t(locale, 'privacy.metaDescription')} />
	<meta property="og:title" content="{t(locale, 'privacy.title')} - Tellbow" />
	<meta property="og:description" content={t(locale, 'privacy.metaDescription')} />
</svelte:head>

<article class="mx-auto max-w-3xl space-y-6">
	<header class="space-y-2">
		<h1 class="text-2xl font-bold tracking-tight text-foreground">{t(locale, 'privacy.title')}</h1>
		<p class="text-xs text-outline">{t(locale, 'privacy.updated')}</p>
	</header>
	<p class="text-foreground">{t(locale, 'privacy.intro')}</p>
	{#each PRIVACY_SECTIONS as section (section)}
		<section class="space-y-2">
			<h2 class="text-lg font-semibold text-foreground">{t(locale, `privacy.${section}Title`)}</h2>
			<p class="text-sm text-muted-foreground">{t(locale, `privacy.${section}`)}</p>
		</section>
	{/each}
</article>
