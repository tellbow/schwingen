import { describe, it, expect, vi } from 'vitest';
import { ClientResponseError } from 'pocketbase';
import { throwLoadError } from './load-error';

function statusOf(cause: unknown): number | undefined {
	try {
		throwLoadError(cause, 'Wrestler not found');
	} catch (e) {
		return (e as { status?: number }).status;
	}
}

describe('throwLoadError', () => {
	it("answers 404 for PocketBase's own 404", () => {
		expect(statusOf(new ClientResponseError({ status: 404 }))).toBe(404);
	});

	it('answers 503 when PocketBase fails or cannot be reached', () => {
		vi.spyOn(console, 'error').mockImplementation(() => {});
		expect(statusOf(new ClientResponseError({ status: 0, isAbort: true }))).toBe(503);
		expect(statusOf(new ClientResponseError({ status: 500 }))).toBe(503);
		expect(statusOf(new TypeError('fetch failed'))).toBe(503);
		expect(statusOf(null)).toBe(503);
	});
});
