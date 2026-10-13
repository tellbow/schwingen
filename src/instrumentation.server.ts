import { metrics } from '@opentelemetry/api';
import { PrometheusExporter } from '@opentelemetry/exporter-prometheus';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { detectResources, envDetector, resourceFromAttributes } from '@opentelemetry/resources';
import { MeterProvider } from '@opentelemetry/sdk-metrics';
import { BatchSpanProcessor, NodeTracerProvider } from '@opentelemetry/sdk-trace-node';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';

const env = process.env;
const enabled = env.OTEL_SDK_DISABLED !== 'true';
const tracing =
	enabled && !!(env.OTEL_EXPORTER_OTLP_ENDPOINT || env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT);
const metricsPort = Number(env.METRICS_PORT) || 0;

const resource = resourceFromAttributes({ [ATTR_SERVICE_NAME]: 'schwingen-frontend' }).merge(
	detectResources({ detectors: [envDetector] })
);
const shutdowns: (() => Promise<void>)[] = [];

if (tracing) {
	const traces = new NodeTracerProvider({
		resource,
		spanProcessors: [new BatchSpanProcessor(new OTLPTraceExporter())]
	});
	traces.register();
	shutdowns.push(() => traces.shutdown());
}

if (enabled && metricsPort) {
	const meters = new MeterProvider({
		resource,
		readers: [new PrometheusExporter({ port: metricsPort })]
	});
	metrics.setGlobalMeterProvider(meters);
	shutdowns.push(() => meters.shutdown());
}

process.on('sveltekit:shutdown', () => {
	void Promise.all(shutdowns.map((shutdown) => shutdown()));
});
