<script lang="ts">
	import { page } from '$app/stores';
	import { Bug } from 'lucide-svelte';
	import { Button } from '$lib/components/ui/button';
	import { t, type Locale } from '$lib/i18n/index.svelte';
	import { reportPlace, sendBugReport, type BugReportResult } from '$lib/utils/bug-report';

	const locale = $derived($page.data.locale as Locale);
	const place = $derived(reportPlace($page.url));

	let dialog = $state<HTMLDialogElement | null>(null);
	let description = $state('');
	let website = $state('');
	let status = $state<'idle' | 'sending' | BugReportResult>('idle');

	function open() {
		if (status === 'sent') description = '';
		status = 'idle';
		dialog?.showModal();
	}

	async function send(event: SubmitEvent) {
		event.preventDefault();
		status = 'sending';
		status = await sendBugReport(fetch, {
			description: description.trim(),
			place,
			platform: 'web',
			system: navigator.userAgent,
			website
		});
	}
</script>

<Button variant="ghost" size="sm" onclick={open} data-testid="bug-open">
	<Bug class="h-4 w-4" />
	{t(locale, 'bugReport.open')}
</Button>

<dialog
	bind:this={dialog}
	aria-labelledby="bug-report-title"
	class="m-auto w-[min(32rem,calc(100vw-2rem))] rounded-xl border border-border bg-card p-0 text-left text-foreground backdrop:bg-foreground/40"
>
	{#if status === 'sent'}
		<div class="flex flex-col gap-4 p-6 text-sm">
			<p role="status">{t(locale, 'bugReport.sent')}</p>
			<Button variant="outline" class="self-end" onclick={() => dialog?.close()}>
				{t(locale, 'bugReport.close')}
			</Button>
		</div>
	{:else}
		<form class="flex flex-col gap-3 p-6 text-sm" onsubmit={send}>
			<h2 id="bug-report-title" class="text-lg font-semibold">{t(locale, 'bugReport.title')}</h2>
			<label class="flex flex-col gap-1 font-medium">
				{t(locale, 'bugReport.what')}
				<textarea
					bind:value={description}
					required
					maxlength="4000"
					rows="5"
					class="w-full rounded-md border border-input bg-background px-3 py-2 font-normal shadow-xs outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 dark:bg-input/30"
					data-testid="bug-text"></textarea>
			</label>
			<input
				bind:value={website}
				name="website"
				tabindex="-1"
				autocomplete="off"
				aria-hidden="true"
				class="absolute -left-[9999px] h-px w-px opacity-0"
			/>
			<p class="text-muted-foreground">
				{t(locale, 'bugReport.privacy').replace('{place}', place)}
			</p>
			{#if status === 'failed' || status === 'busy'}
				<p role="alert" class="text-destructive">
					{t(locale, status === 'busy' ? 'bugReport.busy' : 'bugReport.failed')}
				</p>
			{/if}
			<div class="flex justify-end gap-2">
				<Button type="button" variant="outline" onclick={() => dialog?.close()}>
					{t(locale, 'bugReport.cancel')}
				</Button>
				<Button
					type="submit"
					disabled={status === 'sending' || !description.trim()}
					data-testid="bug-send"
				>
					{t(locale, 'bugReport.send')}
				</Button>
			</div>
		</form>
	{/if}
</dialog>
