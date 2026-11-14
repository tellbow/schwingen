import { describe, it, expect, vi, beforeEach } from 'vitest';

const pocketbase = { up: true };
vi.mock('#lib/pb.js', () => ({
	createServerPb: () => ({
		collection: () => ({
			getFullList: async () => {
				if (!pocketbase.up) throw new Error('PocketBase down');
				return [{ id: 'abc', updated: '2026-01-02 10:00:00.000Z' }];
			}
		})
	})
}));

type Handler = () => Promise<Response>;
let GET: Handler;

beforeEach(async () => {
	vi.resetModules();
	pocketbase.up = true;
	GET = (await import('./+server')).GET as unknown as Handler;
	vi.spyOn(console, 'error').mockImplementation(() => {});
});

describe('GET /sitemap.xml', () => {
	it('answers 503 during an outage and the full sitemap afterwards', async () => {
		pocketbase.up = false;
		const down = await GET();
		expect(down.status).toBe(503);
		expect(down.headers.get('retry-after')).toBe('60');
		pocketbase.up = true;
		expect(await (await GET()).text()).toContain('/wrestler/abc');
	});

	it('keeps serving the last sitemap while PocketBase is down', async () => {
		expect(await (await GET()).text()).toContain('/wrestler/abc');
		vi.useFakeTimers({ now: Date.now() + 2 * 60 * 60 * 1000 });
		pocketbase.up = false;
		const stale = await GET();
		vi.useRealTimers();
		expect(stale.status).toBe(200);
		expect(await stale.text()).toContain('/wrestler/abc');
	});
});
