import { describe, it, expect } from 'vitest';
import { formatDate } from './format';

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
});
