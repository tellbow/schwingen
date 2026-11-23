import { describe, it, expect, vi } from 'vitest';
import type PocketBase from 'pocketbase';
import { countWreaths, fetchWrestlerElo, type ProfileRanking } from './wrestler-profile';

const ranking = (wreath: boolean, type?: string) =>
	({ wreath, expand: { place: { expand: { placeType: { type } } } } }) as unknown as ProfileRanking;

describe('countWreaths', () => {
	it('returns zeros for no rankings', () => {
		expect(countWreaths([])).toEqual([0, 0, 0]);
	});

	it('counts wreaths by festival level and ignores rankings without one', () => {
		const rankings = [
			ranking(true, 'Kantonal'),
			ranking(true, 'Gauverband'),
			ranking(true, 'Berg'),
			ranking(true, 'Teilverband'),
			ranking(true, 'Eidgenössisch'),
			ranking(false, 'Eidgenössisch'),
			ranking(true, 'Regional'),
			ranking(true)
		];
		expect(countWreaths(rankings)).toEqual([2, 2, 1]);
	});
});

function pbWithElo(ratings: Record<string, number>) {
	const getList = vi.fn();
	const pb = {
		collection: (name: string) => ({
			getList: async () => {
				getList(name);
				if (name === 'elo2019') throw new Error('missing view');
				return { items: name in ratings ? [{ id: name, rating: ratings[name] }] : [] };
			}
		})
	} as unknown as PocketBase;
	return { pb, getList };
}

describe('fetchWrestlerElo', () => {
	it('takes the most recent season without asking older ones', async () => {
		const { pb, getList } = pbWithElo({ elo2026: 1500, elo2020: 1200 });
		expect((await fetchWrestlerElo(pb, 'w', 'Alle')).rating).toBe(1500);
		expect(getList).toHaveBeenCalledTimes(1);
	});

	it('falls back to the newest older season with a rating', async () => {
		const { pb } = pbWithElo({ elo2018: 1100, elo2022: 1300 });
		expect((await fetchWrestlerElo(pb, 'w', 'Alle')).rating).toBe(1300);
	});

	it('answers "-" when no season has a rating or a season fails', async () => {
		expect((await fetchWrestlerElo(pbWithElo({}).pb, 'w', 'Alle')).rating).toBe('-');
		expect((await fetchWrestlerElo(pbWithElo({}).pb, 'w', 2019)).rating).toBe('-');
	});
});
