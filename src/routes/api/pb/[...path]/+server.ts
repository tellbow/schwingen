import type { RequestHandler } from '@sveltejs/kit';
import { PB_URL } from '$lib/pb';

const EMPTY_LIST = JSON.stringify({ page: 1, perPage: 1, totalItems: 0, totalPages: 0, items: [] });

// Proxy all requests to PocketBase to avoid CORS issues
export const GET: RequestHandler = async ({ params, url, request }) => {
	const path = params.path ?? '';
	const targetUrl = `${PB_URL}/${path}${url.search}`;

	const response = await fetch(targetUrl, {
		headers: {
			...Object.fromEntries(request.headers),
			host: new URL(PB_URL).host
		}
	});

	if (response.status === 404 && path.includes('/records')) {
		return new Response(EMPTY_LIST, {
			status: 200,
			headers: { 'content-type': 'application/json', 'cache-control': 'no-store' }
		});
	}

	const body = await response.text();
	return new Response(body, {
		status: response.status,
		headers: {
			'content-type': response.headers.get('content-type') || 'application/json',
			'cache-control': 'no-store'
		}
	});
};

export const POST: RequestHandler = async ({ params, url, request }) => {
	const path = params.path ?? '';
	const targetUrl = `${PB_URL}/${path}${url.search}`;
	const body = await request.text();

	const response = await fetch(targetUrl, {
		method: 'POST',
		headers: {
			...Object.fromEntries(request.headers),
			host: new URL(PB_URL).host
		},
		body
	});

	const responseBody = await response.text();
	return new Response(responseBody, {
		status: response.status,
		headers: {
			'content-type': response.headers.get('content-type') || 'application/json'
		}
	});
};
