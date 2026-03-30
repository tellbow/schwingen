import type { Handle } from '@sveltejs/kit';
import { SpanStatusCode, SpanKind } from '@opentelemetry/api';
import { httpRequestsTotal, httpRequestDuration } from '$lib/metrics';
import { getTracer } from '$lib/tracing';

export const handle: Handle = async ({ event, resolve }) => {
	const start = performance.now();
	const path = normalizePath(event.url.pathname);
	const tracer = getTracer();

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
				const response = await resolve(event);
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
