<script lang="ts">
	import { page } from '$app/stores';
	import { Menu, X, Sun, Moon } from 'lucide-svelte';
	import { slide } from 'svelte/transition';
	import { t, getLocale, setLocale, LOCALES, type Locale } from '$lib/i18n/index.svelte';
	import { getDark, toggleDark } from '$lib/dark-mode.svelte';

	let mobileOpen = $state(false);

	const navItems = [
		{ key: 'nav.wrestler', href: '/wrestler' },
		{ key: 'nav.places', href: '/places' },
		{ key: 'nav.statistics', href: '/statistics' },
		{ key: 'nav.head2head', href: '/head2head' },
		{ key: 'nav.associations', href: '/associations' }
	];

	function isActive(href: string): boolean {
		return $page.url.pathname.startsWith(href);
	}
</script>

<header class="bg-surface-lowest shadow-sm">
	<div class="max-w-screen-xl mx-auto px-4">
		<div class="flex items-center h-14">
			<a href="/" class="flex items-center gap-2 mr-6 flex-shrink-0">
				<img src="/images/logos/tellbow_circle.webp" alt="Tellbow" class="h-8 w-8" width="32" height="32" />
				<span class="font-extrabold text-lg tracking-tight text-primary">Tellbow</span>
			</a>

			<nav class="hidden md:flex items-center gap-0.5 flex-1">
				{#each navItems as item}
					<a
						href={item.href}
						class="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors
						{isActive(item.href)
							? 'bg-surface-high text-foreground'
							: 'text-outline hover:bg-surface-low hover:text-foreground'}"
					>
						{t(item.key)}
					</a>
				{/each}
			</nav>

			<div class="hidden md:flex items-center gap-1 ml-2">
				{#each LOCALES as loc}
					<button
						class="px-2 py-0.5 text-xs font-semibold rounded-md transition-colors
						{getLocale() === loc
							? 'bg-primary-container text-white'
							: 'text-outline hover:text-foreground'}"
						onclick={() => setLocale(loc as Locale)}
					>
						{loc.toUpperCase()}
					</button>
				{/each}
				<button
					class="ml-1 p-1.5 rounded-lg text-outline hover:bg-surface-low hover:text-foreground transition-colors"
					onclick={toggleDark}
					aria-label="Dark mode umschalten"
				>
					{#if getDark()}
						<Sun size={16} />
					{:else}
						<Moon size={16} />
					{/if}
				</button>
			</div>

			<button
				class="md:hidden ml-auto p-2 rounded-lg text-outline hover:bg-surface-low transition-colors"
				onclick={() => (mobileOpen = !mobileOpen)}
				aria-label={mobileOpen ? 'Navigation schließen' : 'Navigation öffnen'}
				aria-expanded={mobileOpen}
				aria-controls="mobile-nav"
			>
				{#if mobileOpen}
					<X size={20} />
				{:else}
					<Menu size={20} />
				{/if}
			</button>
		</div>
	</div>

	{#if mobileOpen}
		<nav id="mobile-nav" class="md:hidden bg-surface-low px-4 pb-4 pt-1" transition:slide={{ duration: 150 }}>
			{#each navItems as item}
				<a
					href={item.href}
					class="block py-2.5 text-sm font-medium transition-colors
					{isActive(item.href) ? 'text-primary font-semibold' : 'text-outline hover:text-foreground'}"
					onclick={() => (mobileOpen = false)}
				>
					{t(item.key)}
				</a>
			{/each}
			<div class="flex items-center gap-2 pt-3">
				{#each LOCALES as loc}
					<button
						class="px-2 py-0.5 text-xs font-semibold rounded-md transition-colors
						{getLocale() === loc
							? 'bg-primary-container text-white'
							: 'text-outline hover:text-foreground'}"
						onclick={() => setLocale(loc as Locale)}
					>
						{loc.toUpperCase()}
					</button>
				{/each}
				<button
					class="p-1.5 rounded-lg text-outline hover:text-foreground transition-colors"
					onclick={toggleDark}
					aria-label="Dark mode umschalten"
				>
					{#if getDark()}
						<Sun size={16} />
					{:else}
						<Moon size={16} />
					{/if}
				</button>
			</div>
		</nav>
	{/if}
</header>
