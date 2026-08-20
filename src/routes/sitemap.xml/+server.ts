import type { RequestHandler } from '@sveltejs/kit';
import { createServerPb } from '$lib/pb';

const ORIGIN = 'https://tellbow.ch';
const CACHE_TTL_MS = 60 * 60 * 1000;

let cachedSitemap: { xml: string; generatedAt: number } | null = null;

function url(path: string, lastmod?: string): string {
	const loc = `${ORIGIN}${path}`;
	return lastmod
		? `<url><loc>${loc}</loc><lastmod>${lastmod}</lastmod></url>`
		: `<url><loc>${loc}</loc></url>`;
}

async function generateSitemap(): Promise<string> {
	const pb = createServerPb();

	const [wrestlers, places] = await Promise.all([
		pb.collection('wrestler').getFullList({ fields: 'id,updated', skipTotal: true }).catch(() => []),
		pb.collection('places').getFullList({ fields: 'id,updated', skipTotal: true }).catch(() => [])
	]);

	const staticUrls = [
		url('/'),
		url('/wrestler'),
		url('/places'),
		url('/rankings'),
		url('/statistics'),
		url('/head2head'),
		url('/associations')
	];

	const wrestlerUrls = wrestlers.map((w: any) =>
		url(`/wrestler/${w.id}`, w.updated?.substring(0, 10))
	);

	const placeUrls = places.map((p: any) =>
		url(`/rankings/${p.id}`, p.updated?.substring(0, 10))
	);

	return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${[...staticUrls, ...wrestlerUrls, ...placeUrls].join('\n')}
</urlset>`;
}

export const GET: RequestHandler = async () => {
	if (!cachedSitemap || Date.now() - cachedSitemap.generatedAt > CACHE_TTL_MS) {
		cachedSitemap = { xml: await generateSitemap(), generatedAt: Date.now() };
	}

	return new Response(cachedSitemap.xml, {
		headers: {
			'content-type': 'application/xml',
			'cache-control': 'public, max-age=3600'
		}
	});
};
