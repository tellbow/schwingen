import type { BugReport, Screenshot } from '$lib/types/bug-report';

export const BUG_REPORT_LIMITS = {
	body: 6_000_000,
	screenshotBytes: 4 * 1024 * 1024,
	description: 4000,
	place: 300,
	version: 80,
	system: 300
};

export function parseBugReport(value: unknown, siteVersion: string): BugReport | null {
	if (typeof value !== 'object' || value === null) return null;
	const input = value as Record<string, unknown>;
	const description = typeof input.description === 'string' ? input.description.trim() : '';
	if (!description || description.length > BUG_REPORT_LIMITS.description) return null;
	if (input.platform !== 'web' && input.platform !== 'ios') return null;
	const screenshot = input.screenshot ? parseScreenshot(input.screenshot) : undefined;
	if (screenshot === null) return null;
	return {
		description,
		platform: input.platform,
		place: oneLine(input.place, BUG_REPORT_LIMITS.place),
		version:
			input.platform === 'web' ? siteVersion : oneLine(input.version, BUG_REPORT_LIMITS.version),
		system: oneLine(input.system, BUG_REPORT_LIMITS.system),
		...(screenshot && { screenshot })
	};
}

export function parseScreenshot(value: unknown): Screenshot | null {
	if (typeof value !== 'string' || !/^[A-Za-z0-9+/]+={0,2}$/.test(value)) return null;
	if ((value.length * 3) / 4 > BUG_REPORT_LIMITS.screenshotBytes) return null;
	const head = atob(value.slice(0, 12));
	if (head.startsWith('\xff\xd8\xff')) return { base64: value, extension: 'jpg' };
	if (head.startsWith('\x89PNG')) return { base64: value, extension: 'png' };
	return null;
}

export function isHoneypotFilled(value: unknown): boolean {
	const website = (value as Record<string, unknown> | null)?.website;
	return typeof website === 'string' && website !== '';
}

export function issueTitle(description: string): string {
	const line = description.trim().split('\n')[0].trim();
	return line.length > 80 ? `${line.slice(0, 79)}…` : line;
}

export function issueBody(report: BugReport, screenshotUrl?: string | null): string {
	const code = (value: string) => `\`${(value || '–').replaceAll('`', "'")}\``;
	const screenshot =
		screenshotUrl === undefined
			? []
			: screenshotUrl === null
				? ['- Screenshot: could not be stored']
				: ['', `![Screenshot](${screenshotUrl}?raw=true)`];
	return [
		'~~~~text',
		report.description.replaceAll('~~~~', '~~~'),
		'~~~~',
		'',
		`- Where: ${code(report.place)}`,
		`- Platform: ${report.platform}, version ${code(report.version)}`,
		`- System: ${code(report.system)}`,
		...screenshot,
		'',
		'_Sent with «Fehler melden»._',
		''
	].join('\n');
}

export async function openIssue(
	fetchFn: typeof fetch,
	repo: string,
	token: string,
	report: BugReport,
	now = new Date()
): Promise<void> {
	let screenshotUrl: string | null | undefined;
	if (report.screenshot) {
		screenshotUrl = await storeScreenshot(fetchFn, repo, token, report.screenshot, now).catch(
			(error) => {
				console.error('bug report: screenshot not stored', error);
				return null;
			}
		);
	}
	const response = await fetchFn(`https://api.github.com/repos/${repo}/issues`, {
		method: 'POST',
		headers: githubHeaders(token),
		body: JSON.stringify({
			title: issueTitle(report.description),
			body: issueBody(report, screenshotUrl),
			labels: ['bug']
		}),
		signal: AbortSignal.timeout(15_000)
	});
	if (response.status !== 201) throw new Error(`GitHub answered ${response.status}`);
}

export async function storeScreenshot(
	fetchFn: typeof fetch,
	repo: string,
	token: string,
	screenshot: Screenshot,
	now: Date
): Promise<string> {
	const month = now.toISOString().slice(0, 7);
	const path = `screenshots/${month}/${crypto.randomUUID()}.${screenshot.extension}`;
	const response = await fetchFn(`https://api.github.com/repos/${repo}/contents/${path}`, {
		method: 'PUT',
		headers: githubHeaders(token),
		body: JSON.stringify({ message: 'Screenshot for a bug report', content: screenshot.base64 }),
		signal: AbortSignal.timeout(30_000)
	});
	if (response.status !== 201) throw new Error(`GitHub answered ${response.status}`);
	const stored = (await response.json()) as { content?: { html_url?: string } };
	if (!stored.content?.html_url) throw new Error('GitHub sent no address for the screenshot');
	return stored.content.html_url;
}

function githubHeaders(token: string): Record<string, string> {
	return {
		Authorization: `Bearer ${token}`,
		Accept: 'application/vnd.github+json',
		'Content-Type': 'application/json',
		'X-GitHub-Api-Version': '2022-11-28'
	};
}

export class RateLimiter {
	private hits = new Map<string, number[]>();

	constructor(
		private perKey: number,
		private total: number,
		private windowMs: number
	) {}

	take(key: string, now = Date.now()): boolean {
		this.prune(now);
		const mine = this.hits.get(key) ?? [];
		const all = [...this.hits.values()].reduce((sum, times) => sum + times.length, 0);
		if (mine.length >= this.perKey || all >= this.total) return false;
		this.hits.set(key, [...mine, now]);
		return true;
	}

	refund(key: string): void {
		this.hits.get(key)?.pop();
	}

	private prune(now: number): void {
		for (const [key, times] of this.hits) {
			const recent = times.filter((time) => now - time < this.windowMs);
			if (recent.length) this.hits.set(key, recent);
			else this.hits.delete(key);
		}
	}
}

function oneLine(value: unknown, max: number): string {
	if (typeof value !== 'string') return '';
	return Array.from(value, (char) => (char < ' ' || char === '\u007f' ? ' ' : char))
		.join('')
		.trim()
		.slice(0, max);
}
