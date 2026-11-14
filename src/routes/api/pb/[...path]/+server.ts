import type { RequestHandler } from '@sveltejs/kit';
import { PB_TIMEOUT_MS, PB_URL } from '#lib/pb.js';
import { matchRecordsPath, cacheControlFor } from '#lib/utils/pb-proxy.js';

const EMPTY_LIST = JSON.stringify({ page: 1, perPage: 1, totalItems: 0, totalPages: 0, items: [] });

export const GET: RequestHandler = async ({ params, url, request }) => {
	const path = params.path ?? '';
	const match = matchRecordsPath(path);

	if (!match) {
		return new Response(JSON.stringify({ error: 'Not found' }), {
			status: 404,
			headers: { 'content-type': 'application/json', 'cache-control': 'no-store' }
		});
	}

	const cacheControl = cacheControlFor(match.collection);
	const targetUrl = `${PB_URL}/${path}${url.search}`;

	let response: Response;
	let body: string;
	try {
		response = await fetch(targetUrl, {
			headers: {
				...Object.fromEntries(request.headers),
				host: new URL(PB_URL).host
			},
			signal: AbortSignal.timeout(PB_TIMEOUT_MS)
		});
		body = await response.text();
	} catch (error) {
		console.error('pb proxy: PocketBase unavailable', error);
		return new Response(JSON.stringify({ error: 'PocketBase unavailable' }), {
			status: 503,
			headers: {
				'content-type': 'application/json',
				'cache-control': 'no-store',
				'retry-after': '10'
			}
		});
	}

	// A 404 on a list request just means the (possibly not-yet-created,
	// year-suffixed) collection doesn't exist — treat it as "no results"
	// rather than an error. A 404 on a single-record request means that
	// specific record wasn't found, which callers like getOne()/
	// getFirstListItem() need to see as a real 404 to handle correctly.
	if (response.status === 404 && !match.isSingleRecord) {
		return new Response(EMPTY_LIST, {
			status: 200,
			headers: { 'content-type': 'application/json', 'cache-control': cacheControl }
		});
	}

	return new Response(body, {
		status: response.status,
		headers: {
			'content-type': response.headers.get('content-type') || 'application/json',
			'cache-control': cacheControl
		}
	});
};
