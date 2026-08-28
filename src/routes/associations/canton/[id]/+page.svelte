<script lang="ts">
	import { page } from '$app/stores';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);
</script>

<svelte:head>
	<title>{data.canton?.name ?? t(locale, 'associations.cantonFallbackTitle')} - Tellbow</title>
	<meta name="description" content="{t(locale, 'associations.cantonMetaDescriptionPrefix')} {data.canton?.name ?? ''}." />
	<meta property="og:title" content="{data.canton?.name ?? t(locale, 'associations.cantonFallbackTitle')} - Tellbow" />
	<meta property="og:description" content="{t(locale, 'associations.cantonMetaDescriptionPrefix')} {data.canton?.name ?? ''}." />
</svelte:head>

<div class="max-w-4xl mx-auto">
	{#if data.canton}
		<div class="card mb-4">
			<h1 class="text-xl font-bold">{data.canton.name}</h1>
			<p class="text-sm text-muted-foreground mt-1">
				{data.canton.wrestlerActive} {t(locale, 'associations.activeLabel')} &nbsp;|&nbsp;
				* {data.canton.wrestler1Star} &nbsp;|&nbsp;
				** {data.canton.wrestler2Star} &nbsp;|&nbsp;
				*** {data.canton.wrestler3Star}
			</p>
		</div>
	{:else}
		<h1 class="text-xl font-bold mb-4">{t(locale, 'associations.cantonFallbackTitle')}</h1>
	{/if}

	<div class="card">
		<h2 class="card-title">{t(locale, 'associations.clubs')}</h2>
		{#if data.clubs.length === 0}
			<p class="text-muted-foreground text-sm">{t(locale, 'associations.noClubsFound')}</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full text-sm">
					<thead>
						<tr>
							<th>{t(locale, 'associations.club')}</th>
							<th>{t(locale, 'associations.activeColumnHeader')}</th>
							<th class="hidden md:table-cell">*</th>
							<th class="hidden md:table-cell">**</th>
							<th class="hidden md:table-cell">***</th>
						</tr>
					</thead>
					<tbody>
						{#each data.clubs as club}
							<tr>
								<td class="font-medium">
									<a href="/associations/club/{club.id}" class="underline">{club.name}</a>
								</td>
								<td>{club.wrestlerActive}</td>
								<td class="hidden md:table-cell">{club.wrestler1Star}</td>
								<td class="hidden md:table-cell">{club.wrestler2Star}</td>
								<td class="hidden md:table-cell">{club.wrestler3Star}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
