<script lang="ts">
	import { page } from '$app/stores';
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let { data } = $props();
	const locale = $derived($page.data.locale as Locale);
</script>

<svelte:head>
	<title
		>{data.association?.name ?? t(locale, 'associations.associationFallbackTitle')} - Tellbow</title
	>
	<meta
		name="description"
		content="{t(locale, 'associations.associationMetaDescriptionPrefix')} {data.association?.name ??
			''}."
	/>
	<meta
		property="og:title"
		content="{data.association?.name ??
			t(locale, 'associations.associationFallbackTitle')} - Tellbow"
	/>
	<meta
		property="og:description"
		content="{t(locale, 'associations.associationMetaDescriptionPrefix')} {data.association?.name ??
			''}."
	/>
</svelte:head>

<div class="mx-auto max-w-4xl">
	{#if data.association}
		<div class="card mb-4">
			<h1 class="text-xl font-bold">{data.association.name} ({data.association.abbreviation})</h1>
			<p class="mt-1 text-sm text-muted-foreground">
				{data.association.wrestlerActive}
				{t(locale, 'associations.activeLabel')} &nbsp;|&nbsp; * {data.association.wrestler1Star} &nbsp;|&nbsp;
				** {data.association.wrestler2Star} &nbsp;|&nbsp; *** {data.association.wrestler3Star}
			</p>
		</div>
	{:else}
		<h1 class="mb-4 text-xl font-bold">{t(locale, 'associations.associationFallbackTitle')}</h1>
	{/if}

	<div class="card">
		<h2 class="card-title">{t(locale, 'associations.cantonsGauverbaende')}</h2>
		{#if data.cantons.length === 0}
			<p class="text-sm text-muted-foreground">{t(locale, 'associations.noCantonsFound')}</p>
		{:else}
			<div class="overflow-x-auto">
				<table class="data-table w-full text-sm">
					<thead>
						<tr>
							<th>{t(locale, 'associations.cantonGauverband')}</th>
							<th>{t(locale, 'associations.activeColumnHeader')}</th>
							<th class="hidden md:table-cell">*</th>
							<th class="hidden md:table-cell">**</th>
							<th class="hidden md:table-cell">***</th>
						</tr>
					</thead>
					<tbody>
						{#each data.cantons as canton (canton.id)}
							<tr>
								<td class="font-medium">
									<a href="/associations/canton/{canton.id}" class="underline">{canton.name}</a>
								</td>
								<td>{canton.wrestlerActive}</td>
								<td class="hidden md:table-cell">{canton.wrestler1Star}</td>
								<td class="hidden md:table-cell">{canton.wrestler2Star}</td>
								<td class="hidden md:table-cell">{canton.wrestler3Star}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>
