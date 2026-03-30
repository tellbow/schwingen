import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { resourceFromAttributes } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from '@opentelemetry/semantic-conventions';
import { trace, type Tracer } from '@opentelemetry/api';

const endpoint = typeof process !== 'undefined' ? process.env?.OTEL_EXPORTER_OTLP_ENDPOINT : undefined;

if (endpoint) {
	const sdk = new NodeSDK({
		resource: resourceFromAttributes({
			[ATTR_SERVICE_NAME]: process.env?.OTEL_SERVICE_NAME ?? 'tellbow-frontend',
			[ATTR_SERVICE_VERSION]: '1.0.0'
		}),
		traceExporter: new OTLPTraceExporter({ url: `${endpoint}/v1/traces` }),
		instrumentations: [
			getNodeAutoInstrumentations({
				'@opentelemetry/instrumentation-fs': { enabled: false }
			})
		]
	});

	sdk.start();

	process.on('SIGTERM', () => sdk.shutdown());
}

export function getTracer(): Tracer {
	return trace.getTracer('tellbow');
}
