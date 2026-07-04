import { describe, it, expect } from 'vitest';
import { groupBoutsByWrestler } from './rankings';

describe('groupBoutsByWrestler', () => {
	it('groups bouts by wrestler id', () => {
		const bouts = [
			{ id: '1', wrestler: 'w1' },
			{ id: '2', wrestler: 'w2' },
			{ id: '3', wrestler: 'w1' }
		];

		const result = groupBoutsByWrestler(bouts);

		expect(result.get('w1')).toEqual([
			{ id: '1', wrestler: 'w1' },
			{ id: '3', wrestler: 'w1' }
		]);
		expect(result.get('w2')).toEqual([{ id: '2', wrestler: 'w2' }]);
	});

	it('returns an empty map for an empty list', () => {
		expect(groupBoutsByWrestler([]).size).toBe(0);
	});

	it('returns undefined for a wrestler with no bouts', () => {
		const result = groupBoutsByWrestler([{ id: '1', wrestler: 'w1' }]);
		expect(result.get('unknown')).toBeUndefined();
	});
});
