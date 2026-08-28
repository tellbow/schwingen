import type { Handle } from '@sveltejs/kit';
import { redirect } from '@sveltejs/kit';
import { SpanStatusCode, SpanKind } from '@opentelemetry/api';
import { httpRequestsTotal, httpRequestDuration } from '$lib/metrics';
import { getTracer } from '$lib/tracing';

export const handle: Handle = async ({ event, resolve }) => {
	// German has no URL prefix (it's the default locale), so `/de/...`
	// isn't a route at all — redirect it to the unprefixed equivalent
	// instead of 404ing, since users reasonably expect it to mirror `/fr`.
	if (event.url.pathname === '/de' || event.url.pathname.startsWith('/de/')) {
		const target = event.url.pathname === '/de' ? '/' : event.url.pathname.slice(3);
		redirect(301, `${target}${event.url.search}`);
	}

	const start = performance.now();
	const path = normalizePath(event.url.pathname);
	const tracer = getTracer();
	event.locals.locale = event.url.pathname.startsWith('/fr') ? 'fr' : 'de';

	return tracer.startActiveSpan(
		`${event.request.method} ${path}`,
		{ kind: SpanKind.SERVER },
		async (span) => {
			span.setAttributes({
				'http.method': event.request.method,
				'http.route': path,
				'http.url': event.url.href,
				'http.user_agent': event.request.headers.get('user-agent') ?? ''
			});

			try {
				const response = await resolve(event, {
					transformPageChunk: ({ html }) => html.replace('%lang%', event.locals.locale)
				});
				setSecurityHeaders(response.headers);
				const duration = (performance.now() - start) / 1000;

				span.setAttribute('http.status_code', response.status);
				if (response.status >= 500) {
					span.setStatus({ code: SpanStatusCode.ERROR });
				}

				httpRequestsTotal.inc({
					method: event.request.method,
					path,
					status: String(response.status)
				});
				httpRequestDuration.observe({ method: event.request.method, path }, duration);

				return response;
			} catch (err) {
				span.setStatus({ code: SpanStatusCode.ERROR, message: String(err) });
				span.recordException(err as Error);
				throw err;
			} finally {
				span.end();
			}
		}
	);
};

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

function normalizePath(pathname: string): string {
	return pathname
		.replace(/\/wrestler\/[^/]+/, '/wrestler/:id')
		.replace(/\/rankings\/[^/]+/, '/rankings/:id')
		.replace(/\/head2head\/[^/]+/, '/head2head/:ids')
		.replace(/\/associations\/association\/[^/]+/, '/associations/association/:id')
		.replace(/\/associations\/canton\/[^/]+/, '/associations/canton/:id')
		.replace(/\/associations\/club\/[^/]+/, '/associations/club/:id')
		.replace(/\/api\/pb\/.*/, '/api/pb/:path');
}
