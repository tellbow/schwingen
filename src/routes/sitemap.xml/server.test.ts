import { describe, it, expect, vi, beforeEach } from 'vitest';

const pocketbase = { up: true };
vi.mock('#lib/pb.js', () => ({
	createServerPb: () => ({
		collection: (name: string) => ({
			getFullList: async (options?: { filter?: string }) => {
				if (!pocketbase.up) throw new Error('PocketBase down');
				if (name !== 'places') return [{ id: 'abc', updated: '2026-01-02 10:00:00.000Z' }];
				if (options?.filter === 'rankings_via_place.id != ""')
					return [{ id: 'ranked' }, { id: 'rankedplanned' }];
				if (options?.filter === 'year > @now') return [{ id: 'planned' }, { id: 'rankedplanned' }];
				return [{ id: 'empty' }];
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

	it('lists festivals with rankings or a planned date, each once', async () => {
		const xml = await (await GET()).text();
		expect(xml).toContain('/rankings/ranked<');
		expect(xml).toContain('/rankings/planned<');
		expect(xml.split('<loc>https://schwingen.tellbow.ch/rankings/rankedplanned<')).toHaveLength(2);
		expect(xml).not.toContain('/rankings/empty');
	});
});
