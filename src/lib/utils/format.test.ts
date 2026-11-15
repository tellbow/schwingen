import { describe, it, expect } from 'vitest';
import { formatDate, isPlanned, yearOnly } from './format';

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

describe('isPlanned', () => {
	const now = new Date('2026-11-15T12:00:00Z');

	it('is true for a festival after now', () => {
		expect(isPlanned('2027-01-02 00:00:00.000Z', now)).toBe(true);
	});

	it('is false for a past festival', () => {
		expect(isPlanned('2026-08-30 00:00:00.000Z', now)).toBe(false);
	});

	it('is false for an empty or invalid date', () => {
		expect(isPlanned('', now)).toBe(false);
		expect(isPlanned(null, now)).toBe(false);
		expect(isPlanned('soon', now)).toBe(false);
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
