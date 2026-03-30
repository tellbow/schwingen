import { describe, it, expect } from 'vitest';
import { cn } from './utils';

describe('cn', () => {
	it('returns a single class unchanged', () => {
		expect(cn('foo')).toBe('foo');
	});

	it('combines multiple classes', () => {
		expect(cn('foo', 'bar')).toBe('foo bar');
	});

	it('deduplicates conflicting tailwind classes (last wins)', () => {
		expect(cn('text-red-500', 'text-blue-500')).toBe('text-blue-500');
	});

	it('merges padding overrides correctly', () => {
		expect(cn('p-4', 'px-2')).toBe('p-4 px-2');
	});

	it('handles conditional classes via object syntax', () => {
		expect(cn({ 'font-bold': true, italic: false })).toBe('font-bold');
	});

	it('handles array inputs', () => {
		expect(cn(['foo', 'bar'])).toBe('foo bar');
	});

	it('ignores undefined and null', () => {
		expect(cn('foo', undefined, null, 'bar')).toBe('foo bar');
	});

	it('returns empty string for no args', () => {
		expect(cn()).toBe('');
	});
});
