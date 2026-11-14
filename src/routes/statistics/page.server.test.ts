import { describe, it, expect, vi, beforeEach } from 'vitest';

const pocketbase = { up: true };
vi.mock('#lib/pb.js', () => ({
	createServerPb: () => ({
		collection: () => ({
			getList: async () => {
				if (!pocketbase.up) throw new Error('PocketBase down');
				return { items: [{ id: 'w1', wins: 9, wreath: 3, name: 'Muster', vorname: 'Hans' }] };
			}
		})
	})
}));

type Load = (event: unknown) => Promise<{ mostWins: unknown[] }>;
let load: Load;

beforeEach(async () => {
	vi.resetModules();
	pocketbase.up = true;
	load = (await import('./+page.server')).load as unknown as Load;
});

const request = () => load({ url: new URL('http://localhost/statistics?year=2019') });

describe('statistics load', () => {
	it('does not cache a result in which a query failed', async () => {
		pocketbase.up = false;
		expect((await request()).mostWins).toEqual([]);
		pocketbase.up = true;
		expect((await request()).mostWins).toHaveLength(1);
	});

	it('caches a complete result', async () => {
		expect((await request()).mostWins).toHaveLength(1);
		pocketbase.up = false;
		expect((await request()).mostWins).toHaveLength(1);
	});
});
