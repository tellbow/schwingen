import { describe, it, expect } from 'vitest';
import {
	buildAssociationFeatures,
	buildCantonFeatures,
	buildGauverbandFeatures
} from './associations-map';

const cantonFeatures = [
	{ properties: { name: 'Bern' } },
	{ properties: { name: 'Zürich' } },
	{ properties: { name: 'Obwalden' } },
	{ properties: { name: 'Nidwalden' } },
	{ properties: { name: 'Appenzell Ausserrhoden' } },
	{ properties: { name: 'Appenzell Innerrhoden' } }
];

describe('buildAssociationFeatures', () => {
	it('assigns association wrestlerActive and id to member cantons', () => {
		const result = buildAssociationFeatures(cantonFeatures, [
			{ id: 'bksv-id', abbreviation: 'BKSV', wrestlerActive: 10 }
		]);
		const bern = result.find((f) => f.properties?.name === 'Bern');
		expect(bern?.wrestlerActive).toBe(10);
		expect(bern?.id).toBe('bksv-id');
	});

	it('leaves non-member cantons at zero with no id', () => {
		const result = buildAssociationFeatures(cantonFeatures, [
			{ id: 'bksv-id', abbreviation: 'BKSV', wrestlerActive: 10 }
		]);
		const zurich = result.find((f) => f.properties?.name === 'Zürich');
		expect(zurich?.wrestlerActive).toBe(0);
		expect(zurich?.id).toBeUndefined();
	});

	it('ignores unknown abbreviations', () => {
		const result = buildAssociationFeatures(cantonFeatures, [
			{ id: 'x', abbreviation: 'UNKNOWN', wrestlerActive: 5 }
		]);
		expect(result.every((f) => f.wrestlerActive === 0)).toBe(true);
	});
});

describe('buildCantonFeatures', () => {
	it('sums Bern sub-regions into the Bern tile without exposing a canton id', () => {
		const result = buildCantonFeatures(cantonFeatures, [
			{ id: 'a', name: 'Berner-Jura', association: 'bksv', wrestlerActive: 3 },
			{ id: 'b', name: 'Emmental', association: 'bksv', wrestlerActive: 4 }
		]);
		const bern = result.find((f) => f.properties?.name === 'Bern');
		expect(bern?.wrestlerActive).toBe(7);
		expect(bern?.id).toBeUndefined();
	});

	it('applies a combined canton record to all of its aliased topo tiles', () => {
		const result = buildCantonFeatures(cantonFeatures, [
			{ id: 'ob-nid', name: 'Ob- und Nidwalden', association: 'isv', wrestlerActive: 5 }
		]);
		const obwalden = result.find((f) => f.properties?.name === 'Obwalden');
		const nidwalden = result.find((f) => f.properties?.name === 'Nidwalden');
		expect(obwalden?.wrestlerActive).toBe(5);
		expect(obwalden?.id).toBe('ob-nid');
		expect(nidwalden?.wrestlerActive).toBe(5);
		expect(nidwalden?.id).toBe('ob-nid');
	});

	it('applies the combined Appenzell record to both half-cantons', () => {
		const result = buildCantonFeatures(cantonFeatures, [
			{ id: 'appenzell', name: 'Appenzell', association: 'nosv', wrestlerActive: 2 }
		]);
		expect(result.find((f) => f.properties?.name === 'Appenzell Ausserrhoden')?.id).toBe(
			'appenzell'
		);
		expect(result.find((f) => f.properties?.name === 'Appenzell Innerrhoden')?.id).toBe(
			'appenzell'
		);
	});

	it('maps a direct name match one-to-one', () => {
		const result = buildCantonFeatures(cantonFeatures, [
			{ id: 'zh', name: 'Zürich', association: 'nosv', wrestlerActive: 9 }
		]);
		const zurich = result.find((f) => f.properties?.name === 'Zürich');
		expect(zurich?.wrestlerActive).toBe(9);
		expect(zurich?.id).toBe('zh');
	});

	it('ignores canton records with no matching topo tile', () => {
		const result = buildCantonFeatures(cantonFeatures, [
			{ id: 'x', name: 'Unknown', association: 'nosv', wrestlerActive: 1 }
		]);
		expect(result.every((f) => f.wrestlerActive === 0)).toBe(true);
	});
});

describe('buildGauverbandFeatures', () => {
	it('replaces the Bern tile with per-Gauverband tiles carrying canton ids', () => {
		const cantonLevelFeatures = buildCantonFeatures(cantonFeatures, []);
		const gauverbandFeatures = [
			{ properties: { name: 'Emmental' } },
			{ properties: { name: 'Seeland' } }
		];
		const result = buildGauverbandFeatures(cantonLevelFeatures, gauverbandFeatures, [
			{ id: 'emmental-id', name: 'Emmental', association: 'bksv', wrestlerActive: 6 },
			{ id: 'seeland-id', name: 'Seeland', association: 'bksv', wrestlerActive: 8 }
		]);

		expect(result.find((f) => f.properties?.name === 'Bern')).toBeUndefined();
		expect(result.find((f) => f.properties?.name === 'Zürich')).toBeDefined();

		const emmental = result.find((f) => f.properties?.name === 'Emmental');
		expect(emmental?.id).toBe('emmental-id');
		expect(emmental?.wrestlerActive).toBe(6);
	});

	it('defaults to zero wrestlerActive when no matching canton record exists', () => {
		const cantonLevelFeatures = buildCantonFeatures(cantonFeatures, []);
		const result = buildGauverbandFeatures(
			cantonLevelFeatures,
			[{ properties: { name: 'Oberaargau' } }],
			[]
		);
		const oberaargau = result.find((f) => f.properties?.name === 'Oberaargau');
		expect(oberaargau?.wrestlerActive).toBe(0);
		expect(oberaargau?.id).toBeUndefined();
	});
});
