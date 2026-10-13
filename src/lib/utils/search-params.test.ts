import { describe, it, expect } from 'vitest';
import { buildSearchParams } from './search-params';

describe('buildSearchParams', () => {
	it('keeps only filters with a value, in order', () => {
		expect(buildSearchParams({ name: 'Wenger', vorname: '', year: '2024' }, 1).toString()).toBe(
			'name=Wenger&year=2024'
		);
	});

	it('writes true flags as "true" and drops false ones', () => {
		expect(buildSearchParams({ final: true, wreath: false }, 1).toString()).toBe('final=true');
	});

	it('adds the page only after the first', () => {
		expect(buildSearchParams({}, 1).toString()).toBe('');
		expect(buildSearchParams({ name: 'a' }, 3).toString()).toBe('name=a&page=3');
	});

	it('encodes special characters', () => {
		expect(buildSearchParams({ name: 'Müller & Co' }, 1).toString()).toBe(
			'name=M%C3%BCller+%26+Co'
		);
	});
});
