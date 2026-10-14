import type { BugReportRequest } from '$lib/types/bug-report';

export type BugReportResult = 'sent' | 'busy' | 'failed';

export async function sendBugReport(
	fetchFn: typeof fetch,
	report: BugReportRequest
): Promise<BugReportResult> {
	try {
		const response = await fetchFn('/api/bug-report', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(report)
		});
		if (response.ok) return 'sent';
		return response.status === 429 ? 'busy' : 'failed';
	} catch {
		return 'failed';
	}
}

export function reportPlace(url: URL): string {
	return url.pathname + url.search;
}
