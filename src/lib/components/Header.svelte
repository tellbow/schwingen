<script lang="ts">
	import { page } from '$app/stores';
	import { Menu, X, Sun, Moon } from 'lucide-svelte';
	import { slide } from 'svelte/transition';
	import { t, localizePath, LOCALES, type Locale } from '$lib/i18n/index.svelte';
	import { getDark, toggleDark } from '$lib/dark-mode.svelte';
	import BugReport from '$lib/components/bug-report.svelte';

	let mobileOpen = $state(false);

	const locale = $derived($page.data.locale as Locale);

	const navItems = [
		{ key: 'nav.wrestler', href: '/wrestler' },
		{ key: 'nav.places', href: '/places' },
		{ key: 'nav.statistics', href: '/statistics' },
		{ key: 'nav.head2head', href: '/head2head' },
		{ key: 'nav.associations', href: '/associations' }
	];

	function isActive(href: string): boolean {
		return $page.url.pathname.startsWith(localizePath(href, locale));
	}

	function switchLocaleHref(loc: Locale): string {
		return `${localizePath($page.url.pathname, loc)}${$page.url.search}`;
	}
</script>

<header class="bg-surface-lowest shadow-sm">
	<div class="mx-auto max-w-screen-xl px-4">
		<div class="flex h-14 items-center">
			<a href={localizePath('/', locale)} class="mr-6 flex flex-shrink-0 items-center gap-2">
				<img
					src="/images/logos/tellbow_circle.webp"
					alt="Tellbow"
					class="h-8 w-8"
					width="32"
					height="32"
				/>
				<span class="font-sans text-lg font-semibold tracking-tight text-primary">Tellbow</span>
			</a>

			<nav class="hidden flex-1 items-center gap-0.5 md:flex">
				{#each navItems as item (item.href)}
					<a
						href={localizePath(item.href, locale)}
						class="rounded-lg px-3 py-1.5 text-sm font-medium transition-colors
						{isActive(item.href)
							? 'bg-surface-high text-foreground'
							: 'text-outline hover:bg-surface-low hover:text-foreground'}"
					>
						{t(locale, item.key)}
					</a>
				{/each}
			</nav>

			<div class="ml-2 hidden items-center gap-1 md:flex">
				{#each LOCALES as loc (loc)}
					<a
						href={switchLocaleHref(loc)}
						data-sveltekit-reload
						class="rounded-md px-2 py-0.5 text-xs font-semibold transition-colors
						{locale === loc ? 'bg-primary-container text-white' : 'text-outline hover:text-foreground'}"
					>
						{loc.toUpperCase()}
					</a>
				{/each}
				<button
					class="ml-1 rounded-lg p-1.5 text-outline transition-colors hover:bg-surface-low hover:text-foreground"
					onclick={toggleDark}
					aria-label={t(locale, 'common.toggleDarkMode')}
				>
					{#if getDark()}
						<Sun size={16} />
					{:else}
						<Moon size={16} />
					{/if}
				</button>
			</div>

			<BugReport />

			<button
				class="ml-1 rounded-lg p-2 text-outline transition-colors hover:bg-surface-low md:hidden"
				onclick={() => (mobileOpen = !mobileOpen)}
				aria-label={mobileOpen ? t(locale, 'common.closeNav') : t(locale, 'common.openNav')}
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
		<nav
			id="mobile-nav"
			class="bg-surface-low px-4 pt-1 pb-4 md:hidden"
			transition:slide={{ duration: 150 }}
		>
			{#each navItems as item (item.href)}
				<a
					href={localizePath(item.href, locale)}
					class="block py-2.5 text-sm font-medium transition-colors
					{isActive(item.href) ? 'font-semibold text-primary' : 'text-outline hover:text-foreground'}"
					onclick={() => (mobileOpen = false)}
				>
					{t(locale, item.key)}
				</a>
			{/each}
			<div class="flex items-center gap-2 pt-3">
				{#each LOCALES as loc (loc)}
					<a
						href={switchLocaleHref(loc)}
						data-sveltekit-reload
						class="rounded-md px-2 py-0.5 text-xs font-semibold transition-colors
						{locale === loc ? 'bg-primary-container text-white' : 'text-outline hover:text-foreground'}"
					>
						{loc.toUpperCase()}
					</a>
				{/each}
				<button
					class="rounded-lg p-1.5 text-outline transition-colors hover:text-foreground"
					onclick={toggleDark}
					aria-label={t(locale, 'common.toggleDarkMode')}
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
