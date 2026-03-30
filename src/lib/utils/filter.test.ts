import { describe, it, expect } from 'vitest';
import { escapeFilterValue, buildFilterString, validateRouteParam } from './filter';

describe('escapeFilterValue', () => {
	it('returns empty string for empty input', () => {
		expect(escapeFilterValue('')).toBe('');
	});

	it('passes through plain text unchanged', () => {
		expect(escapeFilterValue('Mueller')).toBe('Mueller');
	});

	it('removes single quotes', () => {
		expect(escapeFilterValue("O'Brien")).toBe('OBrien');
	});

	it('removes double quotes', () => {
		expect(escapeFilterValue('say "hello"')).toBe('say hello');
	});

	it('removes backslashes', () => {
		expect(escapeFilterValue('path\\file')).toBe('pathfile');
	});

	it('removes semicolons', () => {
		expect(escapeFilterValue('a;b')).toBe('ab');
	});

	it('removes parentheses', () => {
		expect(escapeFilterValue('func(arg)')).toBe('funcarg');
	});

	it('trims surrounding whitespace', () => {
		expect(escapeFilterValue('  hello  ')).toBe('hello');
	});

	it('strips injection attempt', () => {
		expect(escapeFilterValue(`" OR 1=1 --`)).toBe('OR 1=1 --');
	});

	it('strips filter escape attempt', () => {
		expect(escapeFilterValue(`value" && id != "x`)).toBe('value && id != x');
	});
});

describe('buildFilterString', () => {
	it('returns empty string for empty filters', () => {
		expect(buildFilterString({})).toBe('');
	});

	it('returns empty string when all values are empty', () => {
		expect(buildFilterString({ name: '', club: '  ' })).toBe('');
	});

	it('builds single field filter', () => {
		expect(buildFilterString({ name: 'Mueller' })).toBe('name ~ "Mueller"');
	});

	it('builds multi-field filter joined with &&', () => {
		const result = buildFilterString({ name: 'Mueller', club: 'Bern' });
		expect(result).toBe('name ~ "Mueller" && club ~ "Bern"');
	});

	it('skips fields with empty values', () => {
		const result = buildFilterString({ name: 'Mueller', club: '' });
		expect(result).toBe('name ~ "Mueller"');
	});

	it('skips fields with whitespace-only values', () => {
		const result = buildFilterString({ name: 'Mueller', club: '   ' });
		expect(result).toBe('name ~ "Mueller"');
	});

	it('escapes special chars in values', () => {
		const result = buildFilterString({ name: "O'Brien" });
		expect(result).toBe('name ~ "OBrien"');
	});
});

describe('validateRouteParam', () => {
	it('returns valid string param', () => {
		expect(validateRouteParam('abc123')).toBe('abc123');
	});

	it('accepts hyphens and underscores', () => {
		expect(validateRouteParam('abc-123_xyz')).toBe('abc-123_xyz');
	});

	it('accepts single character', () => {
		expect(validateRouteParam('a')).toBe('a');
	});

	it('uses first element of array', () => {
		expect(validateRouteParam(['abc', 'xyz'])).toBe('abc');
	});

	it('throws for empty string', () => {
		expect(() => validateRouteParam('')).toThrow('Invalid route parameter');
	});

	it('throws for empty array', () => {
		expect(() => validateRouteParam([])).toThrow('Invalid route parameter');
	});

	it('throws for spaces in value', () => {
		expect(() => validateRouteParam('hello world')).toThrow('Invalid route parameter format');
	});

	it('throws for dots in value', () => {
		expect(() => validateRouteParam('hello.world')).toThrow('Invalid route parameter format');
	});

	it('throws for slash injection', () => {
		expect(() => validateRouteParam('../etc/passwd')).toThrow('Invalid route parameter format');
	});

	it('throws for angle brackets', () => {
		expect(() => validateRouteParam('<script>')).toThrow('Invalid route parameter format');
	});
});
