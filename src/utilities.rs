use anyhow::Result;
use opentelemetry::global;
use opentelemetry_otlp::{MetricExporter, Protocol, WithExportConfig};
use opentelemetry_sdk::{Resource, metrics::SdkMeterProvider};
use tracing::level_filters::LevelFilter;
use tracing_subscriber::{Layer, filter, layer::SubscriberExt, util::SubscriberInitExt};

pub fn initialize_tracing() -> Result<SdkMeterProvider> {
    let target = filter::Targets::new()
        .with_default(LevelFilter::DEBUG)
        .with_target("opentelemetry", LevelFilter::INFO)
        .with_target("tower_http", LevelFilter::DEBUG);

    let fmt = tracing_subscriber::fmt::layer()
        .with_level(true)
        .with_filter(target);

    tracing_subscriber::registry().with(fmt).init();

    let resource = Resource::builder().build();

    if let Ok(metrics_endpoint) = std::env::var("METRICS_ENDPOINT") {
        let exporter = MetricExporter::builder()
            .with_http()
            .with_protocol(Protocol::HttpBinary)
            .with_endpoint(metrics_endpoint)
            .build()
            .expect("Failed to create metric exporter");

        let meter_provider = SdkMeterProvider::builder()
            .with_periodic_exporter(exporter)
            .with_resource(resource)
            .build();

        global::set_meter_provider(meter_provider.clone());

        return Ok(meter_provider);
    }

    let exporter = opentelemetry_stdout::MetricExporter::builder().build();
    let meter_provider = SdkMeterProvider::builder()
        .with_resource(resource)
        .with_periodic_exporter(exporter)
        .build();

    global::set_meter_provider(meter_provider.clone());

    Ok(meter_provider)
}
