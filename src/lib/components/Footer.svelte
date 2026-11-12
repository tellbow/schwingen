<script lang="ts">
	import { page } from '$app/state';
	import { t, localizePath, type Locale } from '#lib/i18n/index.svelte.js';

	const locale = $derived(page.data.locale as Locale);
</script>

<footer class="mt-10 bg-surface-low py-6 text-center text-sm text-outline">
	<p class="font-semibold tracking-tight text-outline">
		© {new Date().getFullYear()} Tellbow – {t(locale, 'footer.tagline')}
	</p>
	<a
		href={localizePath('/privacy', locale)}
		class="mt-2 inline-block underline-offset-4 transition-colors duration-150 hover:text-foreground hover:underline"
		>{t(locale, 'footer.privacy')}</a
	>
</footer>
