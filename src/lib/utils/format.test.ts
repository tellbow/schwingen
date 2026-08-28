import { describe, it, expect } from 'vitest';
import { formatDate, yearOnly } from './format';

describe('yearOnly', () => {
	it('returns empty string for null or undefined', () => {
		expect(yearOnly(null)).toBe('');
		expect(yearOnly(undefined)).toBe('');
	});

	it('returns empty string for empty input', () => {
		expect(yearOnly('')).toBe('');
	});

	it('extracts the year from a full ISO date string', () => {
		expect(yearOnly('2023-05-06 00:00:00.000Z')).toBe('2023');
	});

	it('returns the value unchanged when it has no dash', () => {
		expect(yearOnly('2023')).toBe('2023');
	});
});

describe('formatDate', () => {
	it('returns empty string for null or undefined', () => {
		expect(formatDate(null)).toBe('');
		expect(formatDate(undefined)).toBe('');
	});

	it('returns empty string for empty input', () => {
		expect(formatDate('')).toBe('');
	});

	it('formats a full ISO date string as day.month.year', () => {
		expect(formatDate('2023-05-06 00:00:00.000Z')).toBe('06.05.2023');
	});

	it('returns the original value for an unparsable date', () => {
		expect(formatDate('not-a-date')).toBe('not-a-date');
	});

	it('formats using the given locale instead of the de default', () => {
		expect(formatDate('2023-05-06 00:00:00.000Z', 'fr')).toBe('06/05/2023');
	});
});
