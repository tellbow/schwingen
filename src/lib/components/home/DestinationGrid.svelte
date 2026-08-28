<script lang="ts">
	import { User, MapPin, ArrowLeftRight, Landmark, ChartColumn, ChevronRight } from 'lucide-svelte';
	import { t } from '$lib/i18n/index.svelte';

	let { eloTop5, eloYear }: { eloTop5: Array<{ id: string; name: string; vorname: string; rating: number }>; eloYear: string } = $props();

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

<section class="max-w-screen-xl mx-auto px-4 py-12 md:py-16">
	<p class="text-xs font-bold uppercase tracking-[0.12em] text-outline mb-2">{t('home.discoverEyebrow')}</p>
	<h2 class="font-serif font-semibold text-2xl md:text-3xl text-foreground mb-7">{t('home.discoverHeading')}</h2>

	<div class="flex flex-col gap-4 md:grid md:grid-cols-4 md:auto-rows-[minmax(220px,auto)]">
		<a
			href="/statistics"
			class="group card flex flex-col order-1 md:order-none md:col-start-2 md:col-span-2 md:row-start-1 md:row-span-2"
		>
			<div class="w-12 h-12 rounded-lg bg-tertiary-container/10 flex items-center justify-center mb-4">
				<ChartColumn size={24} class="text-tertiary-container" />
			</div>
			<div class="font-serif font-semibold text-xl text-foreground mb-2">{t('nav.statistics')}</div>
			<p class="text-sm text-muted-foreground leading-relaxed mb-5 max-w-sm">{t('home.statisticsDesc')}</p>

			{#if eloTop5.length > 0}
				<div class="text-[11px] text-outline mb-2">{t('home.statsChartCaption')} {eloYear}</div>
				<div class="flex items-end gap-2 h-20 mb-3">
					{#each eloTop5 as wrestler (wrestler.id)}
						<div
							class="w-6 bg-tertiary-container/50 rounded-t"
							style="height: {barHeight(wrestler.rating)}%"
						></div>
					{/each}
				</div>
				<div class="text-xs text-muted-foreground mb-4">
					{t('home.statsLeader')}: <span class="font-semibold text-foreground">{eloTop5[0].vorname} {eloTop5[0].name}</span> · {eloTop5[0].rating}
				</div>
			{:else}
				<div class="flex-1"></div>
			{/if}

			<span class="inline-flex items-center gap-1 text-sm font-semibold text-primary mt-auto">
				{t('home.show')}
				<ChevronRight size={14} class="transition-transform group-hover:translate-x-0.5" />
			</span>
		</a>

		{#each destinations as dest (dest.titleKey)}
			<a href={dest.href} class="group card flex flex-col {dest.order} {dest.grid}">
				<div class="w-11 h-11 rounded-lg {dest.iconBg} flex items-center justify-center mb-4">
					<dest.icon size={22} class={dest.iconColor} />
				</div>
				<div class="text-base font-semibold text-foreground mb-2">{t(dest.titleKey)}</div>
				<p class="text-sm text-muted-foreground leading-relaxed mb-4 flex-1">{t(dest.descKey)}</p>
				<span class="inline-flex items-center gap-1 text-sm font-semibold text-primary">
					{t('home.show')}
					<ChevronRight size={14} class="transition-transform group-hover:translate-x-0.5" />
				</span>
			</a>
		{/each}
	</div>
</section>
