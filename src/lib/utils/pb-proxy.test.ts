import { describe, it, expect } from 'vitest';
import { matchRecordsPath, cacheControlFor, ALLOWED_COLLECTIONS } from './pb-proxy';

describe('matchRecordsPath', () => {
	it('matches a list request for an allowed collection', () => {
		expect(matchRecordsPath('api/collections/wrestler/records')).toEqual({
			collection: 'wrestler',
			isSingleRecord: false
		});
	});

	it('matches a single-record request for an allowed collection', () => {
		expect(matchRecordsPath('api/collections/wrestler/records/abc123')).toEqual({
			collection: 'wrestler',
			isSingleRecord: true
		});
	});

	it('matches a year-suffixed collection', () => {
		expect(matchRecordsPath('api/collections/elo2024/records')).toEqual({
			collection: 'elo2024',
			isSingleRecord: false
		});
	});

	it('rejects a collection not on the allowlist', () => {
		expect(matchRecordsPath('api/collections/_superusers/records')).toBeNull();
	});

	it('rejects auth and admin endpoints', () => {
		expect(matchRecordsPath('api/collections/wrestler/auth-with-password')).toBeNull();
		expect(matchRecordsPath('api/admins/auth-with-password')).toBeNull();
		expect(matchRecordsPath('api/settings')).toBeNull();
	});

	it('rejects a record id containing path traversal or slashes', () => {
		expect(matchRecordsPath('api/collections/wrestler/records/../_superusers')).toBeNull();
	});
});

describe('cacheControlFor', () => {
	const now = new Date('2026-06-01T00:00:00Z');

	it('does not cache non-year-suffixed collections', () => {
		expect(cacheControlFor('wrestler', now)).toBe('no-store');
	});

	it('does not cache the current season collection', () => {
		expect(cacheControlFor('elo2026', now)).toBe('no-store');
	});

	it('caches a past season collection', () => {
		expect(cacheControlFor('elo2025', now)).toBe('public, max-age=3600');
	});

	it('does not cache a future season collection', () => {
		expect(cacheControlFor('elo2027', now)).toBe('no-store');
	});
});

describe('ALLOWED_COLLECTIONS', () => {
	it('allows every documented public collection', () => {
		for (const name of [
			'wrestler',
			'club',
			'wrestlerStatus',
			'wrestlerMetadata',
			'rankings',
			'bouts',
			'places',
			'placeType',
			'canton',
			'association',
			'drawDecisionRatio',
			'wrestlersByAssociation',
			'wrestlersByCanton',
			'wrestlersByClub',
			'elo2020',
			'averageRank2020',
			'averagePoints2020',
			'mostWins2020',
			'mostWreaths2020',
			'mostPlacesAttended2020'
		]) {
			expect(ALLOWED_COLLECTIONS.test(name)).toBe(true);
		}
	});

	it('rejects the auth-capable users collection', () => {
		expect(ALLOWED_COLLECTIONS.test('users')).toBe(false);
	});
});
