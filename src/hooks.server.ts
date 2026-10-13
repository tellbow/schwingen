import type { Handle } from '@sveltejs/kit';
import { redirect } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import { metrics } from '@opentelemetry/api';
import {
	ATTR_HTTP_REQUEST_METHOD,
	ATTR_HTTP_RESPONSE_STATUS_CODE,
	ATTR_HTTP_ROUTE
} from '@opentelemetry/semantic-conventions';

const requestDuration = metrics
	.getMeter('schwingen-frontend')
	.createHistogram('http.server.request.duration', {
		unit: 's',
		advice: {
			explicitBucketBoundaries: [
				0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1, 2.5, 5, 7.5, 10
			]
		}
	});

const handleMetrics: Handle = async ({ event, resolve }) => {
	const start = performance.now();
	const response = await resolve(event);
	requestDuration.record((performance.now() - start) / 1000, {
		[ATTR_HTTP_REQUEST_METHOD]: event.request.method,
		[ATTR_HTTP_ROUTE]: event.route.id ?? 'unmatched',
		[ATTR_HTTP_RESPONSE_STATUS_CODE]: response.status
	});
	return response;
};

const handlePage: Handle = async ({ event, resolve }) => {
	// German has no URL prefix (it's the default locale), so `/de/...`
	// isn't a route at all — redirect it to the unprefixed equivalent
	// instead of 404ing, since users reasonably expect it to mirror `/fr`.
	if (event.url.pathname === '/de' || event.url.pathname.startsWith('/de/')) {
		const target = event.url.pathname === '/de' ? '/' : event.url.pathname.slice(3);
		redirect(301, `${target}${event.url.search}`);
	}

	event.locals.locale = event.url.pathname.startsWith('/fr') ? 'fr' : 'de';

	const response = await resolve(event, {
		transformPageChunk: ({ html }) => html.replace('%lang%', event.locals.locale)
	});
	setSecurityHeaders(response.headers);
	return response;
};

export const handle: Handle = sequence(handleMetrics, handlePage);

const CSP = [
	"default-src 'self'",
	"script-src 'self' 'unsafe-inline'",
	"style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
	"font-src 'self' https://fonts.gstatic.com",
	"img-src 'self' data:",
	"connect-src 'self'",
	"object-src 'none'",
	"base-uri 'self'",
	"form-action 'self'",
	"frame-ancestors 'none'"
].join('; ');

function setSecurityHeaders(headers: Headers): void {
	headers.set('x-content-type-options', 'nosniff');
	headers.set('x-frame-options', 'DENY');
	headers.set('referrer-policy', 'strict-origin-when-cross-origin');
	headers.set('permissions-policy', 'camera=(), microphone=(), geolocation=()');
	headers.set('strict-transport-security', 'max-age=63072000; includeSubDomains');
	headers.set('content-security-policy', CSP);
}
