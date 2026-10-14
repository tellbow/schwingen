<script lang="ts">
	import { page } from '$app/stores';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	const locale = $derived($page.data.locale as Locale);
</script>

<footer class="mt-10 bg-surface-low py-6 text-center text-sm text-outline">
	<p class="font-semibold tracking-tight text-outline">
		© {new Date().getFullYear()} Tellbow – {t(locale, 'footer.tagline')}
	</p>
</footer>
