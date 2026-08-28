<script lang="ts">
	import { Search } from 'lucide-svelte';
	import { goto } from '$app/navigation';
	import { t } from '$lib/i18n/index.svelte';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { getClientPb } from '$lib/pb';

	let query = $state('');
	let loading = $state(false);

	async function handleSearch(e: SubmitEvent) {
		e.preventDefault();
		const q = query.trim();
		if (!q || loading) return;

		const escaped = escapeFilterValue(q);
		const wrestlerFilter = `name ~ "${escaped}" || vorname ~ "${escaped}" || club.name ~ "${escaped}"`;
		const placesFilter = `name ~ "${escaped}" || location ~ "${escaped}"`;

		loading = true;
		try {
			const pb = getClientPb();
			const [wrestlerCount, placesCount] = await Promise.all([
				pb.collection('wrestler').getList(1, 1, { filter: wrestlerFilter, fields: 'id' }).then((r) => r.totalItems).catch(() => 0),
				pb.collection('places').getList(1, 1, { filter: placesFilter, fields: 'id' }).then((r) => r.totalItems).catch(() => 0)
			]);

			if (wrestlerCount === 0 && placesCount > 0) {
				await goto(`/places?filter=${encodeURIComponent(placesFilter)}`);
			} else {
				await goto(`/wrestler?filter=${encodeURIComponent(wrestlerFilter)}`);
			}
		} finally {
			loading = false;
		}
	}
</script>

<section class="relative overflow-hidden border-b border-border">
	<div
		class="absolute inset-0 pointer-events-none opacity-40"
		style="background-image: repeating-linear-gradient(to bottom, transparent, transparent 27px, var(--color-outline-variant) 28px);"
	></div>
	<div class="absolute -top-52 -right-36 h-[520px] w-[520px] rounded-full border border-primary/15 pointer-events-none"></div>
	<div class="absolute -top-36 -right-16 h-[380px] w-[380px] rounded-full border border-tertiary-container/20 pointer-events-none"></div>

	<div class="relative max-w-screen-xl mx-auto px-4 py-12 md:py-16">
		<div class="max-w-xl">
			<p class="text-xs font-bold uppercase tracking-[0.12em] text-outline mb-3">{t('home.heroEyebrow')}</p>
			<h1 class="font-serif font-semibold text-4xl md:text-5xl leading-[1.1] tracking-tight text-foreground mb-5 text-pretty">
				{t('home.heroHeadline')}
			</h1>
			<p class="text-muted-foreground text-base md:text-lg leading-relaxed mb-8 max-w-md">
				{t('home.heroSubhead')}
			</p>

			<form class="flex items-center gap-3 mb-3" onsubmit={handleSearch}>
				<div class="flex-1 max-w-sm flex items-center gap-2 bg-surface-container rounded-lg px-3 min-h-9">
					<Search size={16} class="text-outline flex-shrink-0" />
					<input
						type="text"
						bind:value={query}
						disabled={loading}
						placeholder={t('home.searchPlaceholder')}
						class="bg-transparent border-0 outline-none text-sm w-full placeholder:text-outline"
					/>
				</div>
				<button type="submit" class="btn-primary whitespace-nowrap" disabled={loading}>
					{loading ? t('common.loading') : t('home.searchButton')}
				</button>
			</form>
			<a href="/rankings" class="text-sm font-semibold hover:underline">{t('home.quickLink')} →</a>
		</div>
	</div>
</section>
