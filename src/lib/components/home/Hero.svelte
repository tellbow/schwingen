<script lang="ts">
	import { Search } from 'lucide-svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';
	import { escapeFilterValue } from '$lib/utils/filter';
	import { getClientPb } from '$lib/pb';

	const locale = $derived($page.data.locale as Locale);

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
				pb
					.collection('wrestler')
					.getList(1, 1, { filter: wrestlerFilter, fields: 'id' })
					.then((r) => r.totalItems)
					.catch(() => 0),
				pb
					.collection('places')
					.getList(1, 1, { filter: placesFilter, fields: 'id' })
					.then((r) => r.totalItems)
					.catch(() => 0)
			]);

			const target =
				wrestlerCount === 0 && placesCount > 0
					? `/places?q=${encodeURIComponent(q)}`
					: `/wrestler?q=${encodeURIComponent(q)}`;
			await goto(localizePath(target, locale));
		} finally {
			loading = false;
		}
	}
</script>

<section class="relative overflow-hidden border-b border-border">
	<div
		class="pointer-events-none absolute inset-0 opacity-40"
		style="background-image: repeating-linear-gradient(to bottom, transparent, transparent 27px, var(--color-outline-variant) 28px);"
	></div>
	<div
		class="pointer-events-none absolute -top-52 -right-36 h-[520px] w-[520px] rounded-full border border-primary/15"
	></div>
	<div
		class="pointer-events-none absolute -top-36 -right-16 h-[380px] w-[380px] rounded-full border border-tertiary-container/20"
	></div>

	<div class="relative mx-auto max-w-screen-xl px-4 pt-8 pb-6 md:pt-10 md:pb-8">
		<div class="max-w-xl">
			<p class="mb-3 text-xs font-bold tracking-[0.12em] text-outline uppercase">
				{t(locale, 'home.heroEyebrow')}
			</p>
			<h1
				class="mb-5 font-serif text-4xl leading-[1.1] font-semibold tracking-tight text-pretty text-foreground md:text-5xl"
			>
				{t(locale, 'home.heroHeadline')}
			</h1>
			<p class="mb-8 max-w-md text-base leading-relaxed text-muted-foreground md:text-lg">
				{t(locale, 'home.heroSubhead')}
			</p>

			<form class="mb-3 flex items-center gap-3" onsubmit={handleSearch}>
				<div
					class="flex min-h-9 max-w-sm flex-1 items-center gap-2 rounded-lg bg-surface-container px-3"
				>
					<Search size={16} class="flex-shrink-0 text-outline" />
					<input
						type="text"
						bind:value={query}
						disabled={loading}
						placeholder={t(locale, 'home.searchPlaceholder')}
						class="w-full border-0 bg-transparent text-sm outline-none placeholder:text-outline"
					/>
				</div>
				<button type="submit" class="btn-primary whitespace-nowrap" disabled={loading}>
					{loading ? t(locale, 'common.loading') : t(locale, 'home.searchButton')}
				</button>
			</form>
		</div>
	</div>
</section>
