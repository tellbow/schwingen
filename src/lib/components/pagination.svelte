<script lang="ts">
	import { t, type Locale } from '$lib/i18n/index.svelte';

	let {
		page,
		totalPages,
		onNavigate,
		locale
	}: { page: number; totalPages: number; onNavigate: (page: number) => void; locale: Locale } =
		$props();

	const pageNumbers = $derived(
		Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
			const half = 2;
			let start = Math.max(1, page - half);
			const end = Math.min(totalPages, start + 4);
			start = Math.max(1, end - 4);
			return start + i;
		})
	);
</script>

{#if totalPages > 1}
	<div class="mt-4 flex flex-col items-center gap-1 py-3">
		<div class="flex gap-1">
			<button class="pagination-btn" disabled={page <= 1} onclick={() => onNavigate(page - 1)}
				>‹</button
			>
			{#each pageNumbers as p (p)}
				<button
					class="pagination-btn {p === page ? 'pagination-active' : ''}"
					onclick={() => onNavigate(p)}>{p}</button
				>
			{/each}
			<button
				class="pagination-btn"
				disabled={page >= totalPages}
				onclick={() => onNavigate(page + 1)}>›</button
			>
		</div>
		<span class="text-sm text-muted-foreground"
			>{t(locale, 'common.page')} {page} {t(locale, 'common.of')} {totalPages}</span
		>
	</div>
{/if}
