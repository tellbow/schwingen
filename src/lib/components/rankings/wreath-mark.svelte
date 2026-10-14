<script lang="ts">
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { locale }: { locale: Locale } = $props();
</script>

<span role="img" aria-label={t(locale, 'rankings.wreath')} title={t(locale, 'rankings.wreath')}
	>🌿</span
>
