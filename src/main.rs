mod errors;
mod middleware;
mod utilities;

use axum::{
    Router, extract::State, http::StatusCode, middleware::from_fn, response::IntoResponse,
    routing::post,
};
use errors::{AppErrors, AppResponse};
use middleware::{validate_body_length, validate_headers};
use opentelemetry_sdk::metrics::SdkMeterProvider;
use std::{env, sync::Arc};
use tokio::{
    net::TcpListener,
    select,
    signal::unix::{SignalKind, signal},
    spawn,
};
use tokio_postgres::{Client, NoTls};
use tower_http::trace::TraceLayer;
use utilities::initialize_tracing;

#[derive(Clone)]
pub struct AppState {
    pub db: Arc<Client>,
}

async fn shutdown_handle(meter_provider: SdkMeterProvider) {
    let mut signal = signal(SignalKind::terminate()).unwrap();
    signal.recv().await;
    meter_provider.shutdown().unwrap();
}

async fn handler(State(state): State<AppState>, body: String) -> AppResponse {
    let event = serde_json::from_str::<serde_json::Value>(&body)
        .map_err(|_| AppErrors::BadEventData(body.clone()))?;

    spawn(async move {
        let event = tokio_postgres::types::Json(event);
        let query = "INSERT INTO events (event, ts) VALUES ($1, now())";

        state.db.execute(query, &[&event]).await
    });

    Ok(StatusCode::ACCEPTED.into_response())
}

async fn server_handle(state: AppState) {
    let listener: TcpListener = TcpListener::bind("0.0.0.0:8000").await.unwrap();
    let service = Router::new()
        .route("/{key}", post(handler))
        .route("/", post(handler))
        .layer(from_fn(validate_body_length))
        .layer(from_fn(validate_headers))
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let _ = axum::serve(listener, service).await;
}

#[tokio::main]
async fn main() {
    let metrics_exporter = initialize_tracing().expect("could not initialize tracing and logging");
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let (client, connection) = tokio_postgres::connect(&database_url, NoTls)
        .await
        .expect("Failed to connect to Postgres");

    spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("Postgres connection error: {}", e);
        }
    });

    let state = AppState {
        db: Arc::new(client),
    };

    select! {
       _ = server_handle(state) => {},
       _ = shutdown_handle(metrics_exporter.clone()) => {}
    }
}
