import { describe, it, expect } from 'vitest';
import {
	escapeFilterValue,
	buildSafeFilter,
	buildQuickSearchFilter,
	sanitizeSort,
	validateRouteParam,
	WRESTLER_STATUS_FILTERS
} from './filter';

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

describe('buildSafeFilter', () => {
	it('returns empty string when no params are set', () => {
		const result = buildSafeFilter(new URLSearchParams(), [
			{ param: 'name', column: 'name', match: 'contains' }
		]);
		expect(result).toBe('');
	});

	it('builds a contains filter', () => {
		const params = new URLSearchParams({ name: 'Mueller' });
		const result = buildSafeFilter(params, [{ param: 'name', column: 'name', match: 'contains' }]);
		expect(result).toBe('name ~ "Mueller"');
	});

	it('builds an equals filter', () => {
		const params = new URLSearchParams({ rank: '1' });
		const result = buildSafeFilter(params, [{ param: 'rank', column: 'rank', match: 'equals' }]);
		expect(result).toBe('rank = "1"');
	});

	it('joins multiple fields with &&', () => {
		const params = new URLSearchParams({ name: 'Mueller', club: 'Bern' });
		const result = buildSafeFilter(params, [
			{ param: 'name', column: 'name', match: 'contains' },
			{ param: 'club', column: 'club.name', match: 'contains' }
		]);
		expect(result).toBe('name ~ "Mueller" && club.name ~ "Bern"');
	});

	it('skips fields whose param is absent', () => {
		const params = new URLSearchParams({ name: 'Mueller' });
		const result = buildSafeFilter(params, [
			{ param: 'name', column: 'name', match: 'contains' },
			{ param: 'club', column: 'club.name', match: 'contains' }
		]);
		expect(result).toBe('name ~ "Mueller"');
	});

	it('escapes special characters in values', () => {
		const params = new URLSearchParams({ name: "O'Brien" });
		const result = buildSafeFilter(params, [{ param: 'name', column: 'name', match: 'contains' }]);
		expect(result).toBe('name ~ "OBrien"');
	});

	it('ignores filter syntax passed as a value instead of building it verbatim', () => {
		const params = new URLSearchParams({ name: '" || id != "' });
		const result = buildSafeFilter(params, [{ param: 'name', column: 'name', match: 'contains' }]);
		expect(result).toBe('name ~ "|| id !="');
	});

	it('renders a boolean field only when the param is exactly "true"', () => {
		const params = new URLSearchParams({ final: 'true' });
		const result = buildSafeFilter(params, [{ param: 'final', column: 'final', match: 'boolean' }]);
		expect(result).toBe('final = true');
	});

	it('ignores a boolean field with any other value', () => {
		const params = new URLSearchParams({ final: 'yes' });
		const result = buildSafeFilter(params, [{ param: 'final', column: 'final', match: 'boolean' }]);
		expect(result).toBe('');
	});

	it('resolves an enum field to its fixed fragment', () => {
		const params = new URLSearchParams({ status: 'eidgenoss' });
		const result = buildSafeFilter(params, [{ param: 'status', enum: WRESTLER_STATUS_FILTERS }]);
		expect(result).toBe("status.symbol = '***'");
	});

	it('ignores an enum field with an unknown value instead of passing it through', () => {
		const params = new URLSearchParams({ status: "' OR 1=1" });
		const result = buildSafeFilter(params, [{ param: 'status', enum: WRESTLER_STATUS_FILTERS }]);
		expect(result).toBe('');
	});

	it('ignores an enum field value that only matches an inherited Object.prototype key', () => {
		const params = new URLSearchParams({ status: '__proto__' });
		const result = buildSafeFilter(params, [{ param: 'status', enum: WRESTLER_STATUS_FILTERS }]);
		expect(result).toBe('');
	});

	it('ignores an enum field value of "toString" or "constructor"', () => {
		const params = new URLSearchParams({ status: 'constructor' });
		const result = buildSafeFilter(params, [{ param: 'status', enum: WRESTLER_STATUS_FILTERS }]);
		expect(result).toBe('');
	});
});

describe('buildQuickSearchFilter', () => {
	it('returns empty string when q is absent', () => {
		const result = buildQuickSearchFilter(new URLSearchParams(), ['name', 'vorname']);
		expect(result).toBe('');
	});

	it('builds an OR filter across the given columns', () => {
		const params = new URLSearchParams({ q: 'Mueller' });
		const result = buildQuickSearchFilter(params, ['name', 'vorname', 'club.name']);
		expect(result).toBe('(name ~ "Mueller" || vorname ~ "Mueller" || club.name ~ "Mueller")');
	});

	it('escapes special characters in the query value', () => {
		const params = new URLSearchParams({ q: "O'Brien" });
		const result = buildQuickSearchFilter(params, ['name']);
		expect(result).toBe('(name ~ "OBrien")');
	});

	it('returns empty string when q escapes to nothing', () => {
		const params = new URLSearchParams({ q: '"' });
		const result = buildQuickSearchFilter(params, ['name']);
		expect(result).toBe('');
	});
});

describe('sanitizeSort', () => {
	it('returns the value when it matches the safe sort pattern', () => {
		expect(sanitizeSort('-status.symbol,name,-created', 'fallback')).toBe(
			'-status.symbol,name,-created'
		);
	});

	it('returns the fallback for null input', () => {
		expect(sanitizeSort(null, 'fallback')).toBe('fallback');
	});

	it('returns the fallback for a value with disallowed characters', () => {
		expect(sanitizeSort('name; DROP TABLE wrestler', 'fallback')).toBe('fallback');
	});

	it('returns the fallback for a value with filter-like syntax', () => {
		expect(sanitizeSort('name" || id != "', 'fallback')).toBe('fallback');
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
