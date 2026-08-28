// Only public, read-only record listing/detail requests for known collections
// are allowed through the /api/pb proxy — it must never reach PocketBase auth
// or admin endpoints, since it is the only path the internet has to PocketBase.
export const ALLOWED_COLLECTIONS =
	/^(wrestler|club|wrestlerStatus|wrestlerMetadata|rankings|bouts|places|placeType|canton|association|drawDecisionRatio|wrestlersByAssociation|wrestlersByCanton|wrestlersByClub|elo\d{4}|averageRank\d{4}|averagePoints\d{4}|mostWins\d{4}|mostWreaths\d{4}|mostPlacesAttended\d{4})$/;

const RECORDS_PATH = /^api\/collections\/([^/]+)\/records(\/[a-zA-Z0-9_-]+)?$/;
const YEAR_SUFFIXED_COLLECTION = /^[a-zA-Z]+(\d{4})$/;

export interface RecordsPathMatch {
	collection: string;
	isSingleRecord: boolean;
}

export function matchRecordsPath(path: string): RecordsPathMatch | null {
	const match = RECORDS_PATH.exec(path);
	if (!match || !ALLOWED_COLLECTIONS.test(match[1])) return null;
	return { collection: match[1], isSingleRecord: Boolean(match[2]) };
}

// Year-suffixed collections (elo2023, mostWins2023, ...) for a past season
// never change once the season is over, so they're safe to cache briefly.
// The current season's collection, and every non-year-scoped collection,
// can still change and must stay uncached.
export function cacheControlFor(collection: string, now: Date = new Date()): string {
	const match = YEAR_SUFFIXED_COLLECTION.exec(collection);
	if (!match) return 'no-store';

	const year = parseInt(match[1]);
	return year < now.getFullYear() ? 'public, max-age=3600' : 'no-store';
}
