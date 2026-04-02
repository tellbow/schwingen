<script lang="ts">
	import { t } from '$lib/i18n/index.svelte';
</script>

<svelte:head>
	<title>Tellbow - Alles rund ums Schwingen</title>
	<meta name="description" content="Entdecken Sie umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern. Verbände, Schwingfeste und detaillierte Analysen." />
</svelte:head>

<div class="max-w-4xl mx-auto">
	<h1 class="sr-only">Tellbow - Alles rund ums Schwingen</h1>

	<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
		<div class="card">
			<h2 class="card-title">{t('nav.wrestler')}</h2>
			<p class="text-muted-foreground text-sm mb-3">
				{t('home.wrestlerDesc')}
			</p>
			<a href="/wrestler" class="btn-primary inline-block">
				{t('home.show')}
			</a>
		</div>

		<div class="card">
			<h2 class="card-title">{t('nav.places')}</h2>
			<p class="text-muted-foreground text-sm mb-3">
				{t('home.placesDesc')}
			</p>
			<a href="/places" class="btn-primary inline-block">
				{t('home.show')}
			</a>
		</div>

		<div class="card">
			<h2 class="card-title">{t('nav.statistics')}</h2>
			<p class="text-muted-foreground text-sm mb-3">
				{t('home.statisticsDesc')}
			</p>
			<a href="/statistics" class="btn-primary inline-block">
				{t('home.show')}
			</a>
		</div>

		<div class="card">
			<h2 class="card-title">{t('nav.head2head')}</h2>
			<p class="text-muted-foreground text-sm mb-3">
				{t('home.head2headDesc')}
			</p>
			<a href="/head2head" class="btn-primary inline-block">
				{t('home.show')}
			</a>
		</div>

		<div class="card">
			<h2 class="card-title">{t('nav.rankings')}</h2>
			<p class="text-muted-foreground text-sm mb-3">
				{t('home.rankingsDesc')}
			</p>
			<a href="/rankings" class="btn-primary inline-block">
				{t('home.show')}
			</a>
		</div>

		<div class="card">
			<h2 class="card-title">{t('nav.associations')}</h2>
			<p class="text-muted-foreground text-sm mb-3">
				{t('home.associationsDesc')}
			</p>
			<a href="/associations" class="btn-primary inline-block">
				{t('home.show')}
			</a>
		</div>
	</div>
</div>
