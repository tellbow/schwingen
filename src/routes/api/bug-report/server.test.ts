import { describe, it, expect, vi, beforeEach } from 'vitest';

const env: Record<string, string | undefined> = {};
vi.mock('$env/dynamic/private', () => ({ env }));

type Handler = (event: unknown) => Promise<Response>;

let POST: Handler;
let github: ReturnType<typeof vi.fn>;

beforeEach(async () => {
	vi.resetModules();
	env.GITHUB_FEEDBACK_TOKEN = 'token';
	env.GITHUB_FEEDBACK_REPO = 'tellbow/schwingen-feedback';
	github = vi.fn(async () => new Response('{}', { status: 201 }));
	POST = (await import('./+server')).POST as unknown as Handler;
	vi.spyOn(console, 'error').mockImplementation(() => {});
});

function send(body: unknown, address = '1.2.3.4') {
	return POST({
		request: new Request('http://localhost/api/bug-report', {
			method: 'POST',
			body: typeof body === 'string' ? body : JSON.stringify(body)
		}),
		fetch: github,
		getClientAddress: () => address
	});
}

const report = { description: 'Rangliste fehlt', place: '/rankings/abc', platform: 'web' };

describe('POST /api/bug-report', () => {
	it('opens an issue for a valid report', async () => {
		const response = await send(report);
		expect(response.status).toBe(201);
		expect(github).toHaveBeenCalledOnce();
	});

	it('rejects invalid input without calling GitHub', async () => {
		expect((await send({ ...report, description: '' })).status).toBe(400);
		expect((await send('not json')).status).toBe(400);
		expect((await send({ ...report, description: 'x'.repeat(5000) })).status).toBe(400);
		expect((await send({ ...report, screenshot: 'x'.repeat(6_000_001) })).status).toBe(413);
		expect(github).not.toHaveBeenCalled();
	});

	it('answers a filled honeypot as sent, without an issue', async () => {
		expect((await send({ ...report, website: 'spam' })).status).toBe(201);
		expect(github).not.toHaveBeenCalled();
	});

	it('limits reports per address', async () => {
		for (let i = 0; i < 5; i++) expect((await send(report)).status).toBe(201);
		expect((await send(report)).status).toBe(429);
		expect((await send(report, '5.6.7.8')).status).toBe(201);
	});

	it('answers 502 when GitHub fails and lets the same report be sent again', async () => {
		github.mockResolvedValueOnce(new Response('down', { status: 500 }));
		expect((await send(report)).status).toBe(502);
		for (let i = 0; i < 5; i++) expect((await send(report)).status).toBe(201);
		expect(github).toHaveBeenCalledTimes(6);
	});

	it('is unavailable without a token', async () => {
		env.GITHUB_FEEDBACK_TOKEN = undefined;
		expect((await send(report)).status).toBe(503);
	});
});
