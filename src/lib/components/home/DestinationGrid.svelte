<script lang="ts">
	import { User, MapPin, ArrowLeftRight, Landmark, ChartColumn, ChevronRight } from 'lucide-svelte';
	import { page } from '$app/stores';
	import { t, localizePath, type Locale } from '$lib/i18n/index.svelte';

	let {
		eloTop5,
		eloYear
	}: {
		eloTop5: Array<{ id: string; name: string; vorname: string; rating: number }>;
		eloYear: string;
	} = $props();

	const locale = $derived($page.data.locale as Locale);

	const maxRating = $derived(Math.max(...eloTop5.map((w) => w.rating), 1));
	const minRating = $derived(Math.min(...eloTop5.map((w) => w.rating), maxRating));

	function barHeight(rating: number): number {
		const range = maxRating - minRating;
		return range > 0 ? 40 + (60 * (rating - minRating)) / range : 70;
	}

	const destinations = [
		{
			icon: User,
			titleKey: 'nav.wrestler',
			descKey: 'home.wrestlerDesc',
			href: '/wrestler',
			iconBg: 'bg-primary/10',
			iconColor: 'text-primary',
			order: 'order-2 md:order-none',
			grid: 'md:col-start-1 md:row-start-1'
		},
		{
			icon: MapPin,
			titleKey: 'nav.places',
			descKey: 'home.placesDesc',
			href: '/places',
			iconBg: 'bg-secondary-solid/10',
			iconColor: 'text-secondary-solid',
			order: 'order-3 md:order-none',
			grid: 'md:col-start-4 md:row-start-1'
		},
		{
			icon: ArrowLeftRight,
			titleKey: 'nav.head2head',
			descKey: 'home.head2headDesc',
			href: '/head2head',
			iconBg: 'bg-primary-container/10',
			iconColor: 'text-primary-container',
			order: 'order-4 md:order-none',
			grid: 'md:col-start-1 md:row-start-2'
		},
		{
			icon: Landmark,
			titleKey: 'nav.associations',
			descKey: 'home.associationsDesc',
			href: '/associations',
			iconBg: 'bg-surface-tint/10',
			iconColor: 'text-surface-tint',
			order: 'order-5 md:order-none',
			grid: 'md:col-start-4 md:row-start-2'
		}
	];
</script>

<section class="mx-auto max-w-screen-xl px-4 pt-6 pb-12 md:pt-8 md:pb-16">
	<p class="mb-2 text-xs font-bold tracking-[0.12em] text-outline uppercase">
		{t(locale, 'home.discoverEyebrow')}
	</p>
	<h2 class="mb-7 font-serif text-2xl font-semibold text-foreground md:text-3xl">
		{t(locale, 'home.discoverHeading')}
	</h2>

	<div class="flex flex-col gap-4 md:grid md:auto-rows-[minmax(220px,auto)] md:grid-cols-4">
		<a
			href={localizePath('/statistics', locale)}
			class="group card order-1 flex flex-col md:order-none md:col-span-2 md:col-start-2 md:row-span-2 md:row-start-1"
		>
			<div
				class="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-tertiary-container/10"
			>
				<ChartColumn size={24} class="text-tertiary-container" />
			</div>
			<div class="mb-2 font-serif text-xl font-semibold text-foreground">
				{t(locale, 'nav.statistics')}
			</div>
			<p class="mb-5 max-w-sm text-sm leading-relaxed text-muted-foreground">
				{t(locale, 'home.statisticsDesc')}
			</p>

			{#if eloTop5.length > 0}
				<div class="mb-2 text-[11px] text-outline">
					{t(locale, 'home.statsChartCaption')}
					{eloYear}
				</div>
				<div class="mb-3 flex h-20 items-end gap-2">
					{#each eloTop5 as wrestler (wrestler.id)}
						<div
							class="w-6 rounded-t bg-tertiary-container/50"
							style="height: {barHeight(wrestler.rating)}%"
						></div>
					{/each}
				</div>
				<div class="mb-4 text-xs text-muted-foreground">
					{t(locale, 'home.statsLeader')}:
					<span class="font-semibold text-foreground">{eloTop5[0].vorname} {eloTop5[0].name}</span>
					· {eloTop5[0].rating}
				</div>
			{:else}
				<div class="flex-1"></div>
			{/if}

			<span class="mt-auto inline-flex items-center gap-1 text-sm font-semibold text-primary">
				{t(locale, 'home.show')}
				<ChevronRight size={14} class="transition-transform group-hover:translate-x-0.5" />
			</span>
		</a>

		{#each destinations as dest (dest.titleKey)}
			<a
				href={localizePath(dest.href, locale)}
				class="group card flex flex-col {dest.order} {dest.grid}"
			>
				<div class="h-11 w-11 rounded-lg {dest.iconBg} mb-4 flex items-center justify-center">
					<dest.icon size={22} class={dest.iconColor} />
				</div>
				<div class="mb-2 text-base font-semibold text-foreground">{t(locale, dest.titleKey)}</div>
				<p class="mb-4 flex-1 text-sm leading-relaxed text-muted-foreground">
					{t(locale, dest.descKey)}
				</p>
				<span class="inline-flex items-center gap-1 text-sm font-semibold text-primary">
					{t(locale, 'home.show')}
					<ChevronRight size={14} class="transition-transform group-hover:translate-x-0.5" />
				</span>
			</a>
		{/each}
	</div>
</section>
