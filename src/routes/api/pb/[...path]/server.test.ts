import { describe, it, expect, vi, afterEach } from 'vitest';
import { GET } from './+server';

type Handler = (event: unknown) => Promise<Response>;
const get = GET as unknown as Handler;

function request(path = 'api/collections/wrestler/records') {
	return get({
		params: { path },
		url: new URL(`http://localhost/api/pb/${path}?perPage=1`),
		request: new Request(`http://localhost/api/pb/${path}?perPage=1`)
	});
}

afterEach(() => {
	vi.unstubAllGlobals();
});

describe('GET /api/pb/[...path]', () => {
	it('answers 503 when PocketBase is unreachable', async () => {
		vi.spyOn(console, 'error').mockImplementation(() => {});
		vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('Unable to connect')));
		const response = await request();
		expect(response.status).toBe(503);
		expect(response.headers.get('cache-control')).toBe('no-store');
	});

	it('gives up on a PocketBase that does not answer within the timeout', async () => {
		vi.spyOn(console, 'error').mockImplementation(() => {});
		const timeout = vi
			.spyOn(AbortSignal, 'timeout')
			.mockReturnValue(AbortSignal.abort(new DOMException('timed out', 'TimeoutError')));
		vi.stubGlobal(
			'fetch',
			vi.fn(async (_url: string, init: RequestInit) => {
				init.signal?.throwIfAborted();
				return new Response('{}');
			})
		);
		expect((await request()).status).toBe(503);
		expect(timeout).toHaveBeenCalledWith(8_000);
		timeout.mockRestore();
	});

	it('passes the answer through', async () => {
		vi.stubGlobal(
			'fetch',
			vi.fn().mockResolvedValue(new Response('{"items":[]}', { status: 200 }))
		);
		const response = await request();
		expect(response.status).toBe(200);
		expect(await response.text()).toBe('{"items":[]}');
	});
});
