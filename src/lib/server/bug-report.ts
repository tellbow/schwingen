import type { BugReport } from '$lib/types/bug-report';

export const BUG_REPORT_LIMITS = {
	body: 16_000,
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
	return {
		description,
		platform: input.platform,
		place: oneLine(input.place, BUG_REPORT_LIMITS.place),
		version:
			input.platform === 'web' ? siteVersion : oneLine(input.version, BUG_REPORT_LIMITS.version),
		system: oneLine(input.system, BUG_REPORT_LIMITS.system)
	};
}

export function isHoneypotFilled(value: unknown): boolean {
	const website = (value as Record<string, unknown> | null)?.website;
	return typeof website === 'string' && website !== '';
}

export function issueTitle(description: string): string {
	const line = description.trim().split('\n')[0].trim();
	return line.length > 80 ? `${line.slice(0, 79)}…` : line;
}

export function issueBody(report: BugReport): string {
	const code = (value: string) => `\`${(value || '–').replaceAll('`', "'")}\``;
	return [
		'~~~~text',
		report.description.replaceAll('~~~~', '~~~'),
		'~~~~',
		'',
		`- Where: ${code(report.place)}`,
		`- Platform: ${report.platform}, version ${code(report.version)}`,
		`- System: ${code(report.system)}`,
		'',
		'_Sent with «Fehler melden»._',
		''
	].join('\n');
}

export async function openIssue(
	fetchFn: typeof fetch,
	repo: string,
	token: string,
	report: BugReport
): Promise<void> {
	const response = await fetchFn(`https://api.github.com/repos/${repo}/issues`, {
		method: 'POST',
		headers: {
			Authorization: `Bearer ${token}`,
			Accept: 'application/vnd.github+json',
			'Content-Type': 'application/json',
			'X-GitHub-Api-Version': '2022-11-28'
		},
		body: JSON.stringify({
			title: issueTitle(report.description),
			body: issueBody(report),
			labels: ['bug']
		}),
		signal: AbortSignal.timeout(15_000)
	});
	if (response.status !== 201) throw new Error(`GitHub answered ${response.status}`);
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
