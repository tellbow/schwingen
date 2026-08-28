<script lang="ts">
	import { CalendarDays, Globe, TrendingUp, Shield } from 'lucide-svelte';
	import { t } from '$lib/i18n/index.svelte';

	const pillars = [
		{ icon: CalendarDays, labelKey: 'home.statSinceLabel', captionKey: 'home.statSinceCaption' },
		{ icon: Globe, labelKey: 'home.statBilingualLabel', captionKey: 'home.statBilingualCaption' },
		{ icon: TrendingUp, labelKey: 'home.statEloLabel', captionKey: 'home.statEloCaption' },
		{ icon: Shield, labelKey: 'home.statCantonsLabel', captionKey: 'home.statCantonsCaption' }
	];
</script>

<section class="bg-surface-lowest border-b border-border">
	<div class="max-w-screen-xl mx-auto px-4 py-6 grid grid-cols-2 md:grid-cols-4 gap-6">
		{#each pillars as pillar, i (pillar.labelKey)}
			<div class={i > 0 ? 'md:border-l md:border-border md:pl-6' : ''}>
				<pillar.icon size={20} class="text-primary mb-2" />
				<div class="font-serif font-semibold text-lg text-foreground">{t(pillar.labelKey)}</div>
				<div class="text-xs text-muted-foreground mt-0.5">{t(pillar.captionKey)}</div>
			</div>
		{/each}
	</div>
</section>
