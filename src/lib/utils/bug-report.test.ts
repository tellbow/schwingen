import { describe, it, expect, vi } from 'vitest';
import { reportPlace, sendBugReport } from './bug-report';

const report = { description: 'Fehler', place: '/', platform: 'web' as const };

describe('sendBugReport', () => {
	it('posts the report as JSON to the endpoint', async () => {
		const fetchFn = vi.fn(async () => new Response('{}', { status: 201 }));
		expect(await sendBugReport(fetchFn, report)).toBe('sent');
		const [url, init] = fetchFn.mock.calls[0] as unknown as [string, RequestInit];
		expect(url).toBe('/api/bug-report');
		expect(JSON.parse(init.body as string)).toEqual(report);
	});

	it('tells a rate limit apart from other failures', async () => {
		expect(await sendBugReport(async () => new Response('', { status: 429 }), report)).toBe('busy');
		expect(await sendBugReport(async () => new Response('', { status: 502 }), report)).toBe(
			'failed'
		);
		expect(
			await sendBugReport(async () => {
				throw new TypeError('offline');
			}, report)
		).toBe('failed');
	});
});

describe('reportPlace', () => {
	it('is the path with the query, without host or hash', () => {
		expect(reportPlace(new URL('https://schwingen.tellbow.ch/fr/rankings?page=2#top'))).toBe(
			'/fr/rankings?page=2'
		);
	});
});
