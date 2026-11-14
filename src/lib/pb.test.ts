import { afterEach, describe, expect, it, vi } from 'vitest';
import { createServerPb, getClientPb } from './pb';

const emptyList = { page: 1, perPage: 10, totalItems: 0, totalPages: 0, items: [] };

function stubMemoryStorage() {
	const items = new Map<string, string>();
	vi.stubGlobal('localStorage', {
		getItem: (key: string) => items.get(key) ?? null,
		setItem: (key: string, value: string) => items.set(key, value),
		removeItem: (key: string) => items.delete(key)
	});
}

function stubSlowFetch() {
	vi.stubGlobal(
		'fetch',
		vi.fn(async (_url: string, init?: RequestInit) => {
			await new Promise((resolve) => setTimeout(resolve, 10));
			if (init?.signal?.aborted) throw new DOMException('aborted', 'AbortError');
			return new Response(JSON.stringify(emptyList), {
				status: 200,
				headers: { 'content-type': 'application/json' }
			});
		})
	);
}

describe('getClientPb', () => {
	afterEach(() => vi.unstubAllGlobals());

	it('lets parallel queries on the same collection all finish', async () => {
		stubMemoryStorage();
		stubSlowFetch();
		const pb = getClientPb();
		const results = await Promise.allSettled([
			pb.collection('bouts').getList(1, 10, { filter: 'wrestler = "a"' }),
			pb.collection('bouts').getList(1, 10, { filter: 'wrestler = "a" && result = "o"' })
		]);
		expect(results.map((r) => r.status)).toEqual(['fulfilled', 'fulfilled']);
	});

	it('returns the same client every time', () => {
		expect(getClientPb()).toBe(getClientPb());
	});
});

describe('createServerPb', () => {
	afterEach(() => {
		vi.unstubAllGlobals();
		vi.restoreAllMocks();
	});

	it('gives up on a PocketBase that does not answer within the timeout', async () => {
		const timeout = vi
			.spyOn(AbortSignal, 'timeout')
			.mockReturnValue(AbortSignal.abort(new DOMException('timed out', 'TimeoutError')));
		vi.stubGlobal(
			'fetch',
			vi.fn(async (_url: string, init?: RequestInit) => {
				init?.signal?.throwIfAborted();
				return Response.json(emptyList);
			})
		);
		await expect(createServerPb().collection('wrestler').getList(1, 1)).rejects.toThrow();
		expect(timeout).toHaveBeenCalledWith(8_000);
	});

	it('answers normally within the timeout', async () => {
		vi.stubGlobal(
			'fetch',
			vi.fn(async () => Response.json(emptyList))
		);
		expect((await createServerPb().collection('wrestler').getList(1, 1)).items).toEqual([]);
	});
});
