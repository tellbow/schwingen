import { describe, it, expect } from 'vitest';
import { computeBoutCounts, computeAverageRank, computeAveragePoints, computeWinRate } from './wrestler-stats';

describe('computeBoutCounts', () => {
	it('returns zeros for an empty list', () => {
		expect(computeBoutCounts([])).toEqual({ win: 0, draw: 0, loss: 0 });
	});

	it('counts +, -, and o characters across all results', () => {
		const rankings = [{ result: '++o' }, { result: '-+' }, { result: 'o--' }];
		expect(computeBoutCounts(rankings)).toEqual({ win: 3, draw: 3, loss: 2 });
	});
});

describe('computeAverageRank', () => {
	it('returns "-" when fewer than 5 entries', () => {
		const rankings = [{ rank: '1', status: '' }, { rank: '2', status: '' }];
		expect(computeAverageRank(rankings)).toBe('-');
	});

	it('averages numeric rank, stripping non-digit suffixes', () => {
		const rankings = [
			{ rank: '1', status: '' },
			{ rank: '2b', status: '' },
			{ rank: '3', status: '' },
			{ rank: '4', status: '' },
			{ rank: '5', status: '' }
		];
		expect(computeAverageRank(rankings)).toBe('3.00');
	});

	it('excludes entries with status "Unfall"', () => {
		const rankings = [
			{ rank: '1', status: '' },
			{ rank: '2', status: '' },
			{ rank: '3', status: '' },
			{ rank: '4', status: '' },
			{ rank: '5', status: '' },
			{ rank: '100', status: 'Unfall' }
		];
		expect(computeAverageRank(rankings)).toBe('3.00');
	});
});

describe('computeAveragePoints', () => {
	const base = { status: '', expand: { place: { expand: { placeType: { type: 'Kantonal' } } } } };

	it('returns "-" when fewer than 5 entries', () => {
		expect(computeAveragePoints([{ ...base, points: '10' }])).toBe('-');
	});

	it('averages points across at least 5 entries', () => {
		const rankings = Array.from({ length: 5 }, () => ({ ...base, points: '10' }));
		expect(computeAveragePoints(rankings)).toBe('10.00');
	});

	it('excludes entries at an "Eidgenössisch" place type', () => {
		const rankings = [
			...Array.from({ length: 5 }, () => ({ ...base, points: '10' })),
			{
				status: '',
				points: '1000',
				expand: { place: { expand: { placeType: { type: 'Eidgenössisch' } } } }
			}
		];
		expect(computeAveragePoints(rankings)).toBe('10.00');
	});

	it('excludes entries with status "Unfall"', () => {
		const rankings = [
			...Array.from({ length: 5 }, () => ({ ...base, points: '10' })),
			{ ...base, points: '1000', status: 'Unfall' }
		];
		expect(computeAveragePoints(rankings)).toBe('10.00');
	});
});

describe('computeWinRate', () => {
	it('returns 0 when there are no bouts', () => {
		expect(computeWinRate({ win: 0, draw: 0, loss: 0 })).toBe(0);
	});

	it('computes the rounded win percentage', () => {
		expect(computeWinRate({ win: 1, draw: 1, loss: 1 })).toBe(33);
		expect(computeWinRate({ win: 3, draw: 0, loss: 1 })).toBe(75);
	});
});
