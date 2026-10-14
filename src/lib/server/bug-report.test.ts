import { describe, it, expect, vi } from 'vitest';
import {
	RateLimiter,
	isHoneypotFilled,
	issueBody,
	issueTitle,
	openIssue,
	parseBugReport,
	parseScreenshot
} from './bug-report';

const jpeg = '/9j/4AAQSkZJRgABAQ==';
const png = 'iVBORw0KGgoAAAANSUhEUg==';

const input = { description: 'Rangliste fehlt', place: '/rankings/abc', platform: 'web' };

describe('parseBugReport', () => {
	it('keeps the description and the context, with the site version for the web', () => {
		expect(parseBugReport({ ...input, version: 'fake', system: 'Firefox' }, '2.1.3')).toEqual({
			description: 'Rangliste fehlt',
			place: '/rankings/abc',
			platform: 'web',
			version: '2.1.3',
			system: 'Firefox'
		});
	});

	it('takes the version the app sends', () => {
		expect(
			parseBugReport({ ...input, platform: 'ios', version: '0.1.0 (1)' }, '2.1.3')?.version
		).toBe('0.1.0 (1)');
	});

	it('rejects a missing or too long description and unknown platforms', () => {
		expect(parseBugReport({ ...input, description: '   ' }, 'v')).toBeNull();
		expect(parseBugReport({ ...input, description: 'x'.repeat(4001) }, 'v')).toBeNull();
		expect(parseBugReport({ ...input, platform: 'android' }, 'v')).toBeNull();
		expect(parseBugReport('text', 'v')).toBeNull();
		expect(parseBugReport(null, 'v')).toBeNull();
	});

	it('puts the context on one line and caps it', () => {
		const report = parseBugReport({ ...input, place: '/a\n# Title', system: 'y'.repeat(400) }, 'v');
		expect(report?.place).toBe('/a # Title');
		expect(report?.system).toHaveLength(300);
	});
});

describe('parseScreenshot', () => {
	it('takes JPEG and PNG by their first bytes', () => {
		expect(parseScreenshot(jpeg)).toEqual({ base64: jpeg, extension: 'jpg' });
		expect(parseScreenshot(png)).toEqual({ base64: png, extension: 'png' });
	});

	it('rejects other formats, broken base64 and pictures over 4 MB', () => {
		expect(parseScreenshot('R0lGODlhAQABAAAAACw=')).toBeNull();
		expect(parseScreenshot('data:image/jpeg;base64,' + jpeg)).toBeNull();
		expect(parseScreenshot(42)).toBeNull();
		expect(parseScreenshot(jpeg + 'A'.repeat(5_600_000))).toBeNull();
	});

	it('makes a report with a broken screenshot invalid, and keeps a good one', () => {
		expect(parseBugReport({ ...input, screenshot: 'R0lGODlhAQABAAAAACw=' }, 'v')).toBeNull();
		expect(parseBugReport({ ...input, screenshot: png }, 'v')?.screenshot?.extension).toBe('png');
		expect(parseBugReport(input, 'v')).not.toHaveProperty('screenshot');
	});
});

describe('isHoneypotFilled', () => {
	it('is true only when the hidden field has text', () => {
		expect(isHoneypotFilled({ website: 'http://spam' })).toBe(true);
		expect(isHoneypotFilled({ website: '' })).toBe(false);
		expect(isHoneypotFilled({})).toBe(false);
		expect(isHoneypotFilled(null)).toBe(false);
	});
});

describe('issue text', () => {
	it('titles with the first line, at most 80 characters', () => {
		expect(issueTitle('  Falscher Rang\nmehr dazu')).toBe('Falscher Rang');
		expect(issueTitle('a'.repeat(100))).toBe(`${'a'.repeat(79)}…`);
	});

	it('fences the description and quotes the context', () => {
		const body = issueBody({
			description: 'kaputt ~~~~ @someone',
			place: '/x`y',
			platform: 'ios',
			version: '0.1.0',
			system: ''
		});
		expect(body).toContain('~~~~text\nkaputt ~~~ @someone\n~~~~');
		expect(body).toContain("- Where: `/x'y`");
		expect(body).toContain('- Platform: ios, version `0.1.0`');
		expect(body).toContain('- System: `–`');
		expect(body).not.toContain('Screenshot');
	});

	it('shows a stored screenshot and says when one was lost', () => {
		const report = {
			description: 'x',
			place: '/',
			platform: 'web' as const,
			version: '',
			system: ''
		};
		expect(issueBody(report, 'https://github.com/o/r/blob/main/s.jpg')).toContain(
			'![Screenshot](https://github.com/o/r/blob/main/s.jpg?raw=true)'
		);
		expect(issueBody(report, null)).toContain('- Screenshot: could not be stored');
	});
});

describe('openIssue', () => {
	const report = {
		description: 'Fehler',
		place: '/',
		platform: 'web' as const,
		version: 'dev',
		system: ''
	};

	it('opens a bug issue in the repo with the token', async () => {
		const fetchFn = vi.fn(async () => new Response('{}', { status: 201 }));
		await openIssue(fetchFn, 'tellbow/schwingen-feedback', 'secret', report);
		const [url, init] = fetchFn.mock.calls[0] as unknown as [string, RequestInit];
		expect(url).toBe('https://api.github.com/repos/tellbow/schwingen-feedback/issues');
		expect((init.headers as Record<string, string>).Authorization).toBe('Bearer secret');
		expect(JSON.parse(init.body as string)).toMatchObject({ title: 'Fehler', labels: ['bug'] });
	});

	it('stores the screenshot in the repo first and shows it in the issue', async () => {
		const stored =
			'https://github.com/tellbow/schwingen-feedback/blob/main/screenshots/2026-10/a.jpg';
		const fetchFn = vi.fn(async (url: string) =>
			url.includes('/contents/')
				? Response.json({ content: { html_url: stored } }, { status: 201 })
				: new Response('{}', { status: 201 })
		);
		await openIssue(
			fetchFn as unknown as typeof fetch,
			'tellbow/schwingen-feedback',
			'secret',
			{ ...report, screenshot: { base64: jpeg, extension: 'jpg' } },
			new Date('2026-10-14T12:00:00Z')
		);
		const [[putUrl, put], [, post]] = fetchFn.mock.calls as unknown as [string, RequestInit][];
		expect(putUrl).toMatch(
			/^https:\/\/api\.github\.com\/repos\/tellbow\/schwingen-feedback\/contents\/screenshots\/2026-10\/[0-9a-f-]{36}\.jpg$/
		);
		expect(put.method).toBe('PUT');
		expect(JSON.parse(put.body as string).content).toBe(jpeg);
		expect(JSON.parse(post.body as string).body).toContain(`![Screenshot](${stored}?raw=true)`);
	});

	it('still opens the issue when the screenshot cannot be stored', async () => {
		vi.spyOn(console, 'error').mockImplementation(() => {});
		const fetchFn = vi.fn(async (url: string) =>
			url.includes('/contents/')
				? new Response('', { status: 403 })
				: new Response('{}', { status: 201 })
		);
		await openIssue(fetchFn as unknown as typeof fetch, 'r', 't', {
			...report,
			screenshot: { base64: png, extension: 'png' }
		});
		const [, post] = fetchFn.mock.calls[1] as unknown as [string, RequestInit];
		expect(JSON.parse(post.body as string).body).toContain('could not be stored');
	});

	it('fails when GitHub does not create the issue', async () => {
		const fetchFn = vi.fn(async () => new Response('nope', { status: 403 }));
		await expect(openIssue(fetchFn, 'r', 't', report)).rejects.toThrow('403');
	});
});

describe('RateLimiter', () => {
	it('allows a few per key and window, then again after the window', () => {
		const limiter = new RateLimiter(2, 100, 1000);
		expect(limiter.take('a', 0)).toBe(true);
		expect(limiter.take('a', 10)).toBe(true);
		expect(limiter.take('a', 20)).toBe(false);
		expect(limiter.take('b', 20)).toBe(true);
		expect(limiter.take('a', 1001)).toBe(true);
	});

	it('caps all keys together', () => {
		const limiter = new RateLimiter(5, 2, 1000);
		expect(limiter.take('a', 0)).toBe(true);
		expect(limiter.take('b', 0)).toBe(true);
		expect(limiter.take('c', 0)).toBe(false);
	});

	it('gives a refunded attempt back', () => {
		const limiter = new RateLimiter(1, 10, 1000);
		expect(limiter.take('a', 0)).toBe(true);
		limiter.refund('a');
		expect(limiter.take('a', 1)).toBe(true);
	});
});
