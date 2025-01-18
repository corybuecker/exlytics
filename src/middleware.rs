use crate::AppErrors;
use axum::body::{Body, to_bytes};
use axum::extract::Request;
use axum::http::{HeaderMap, header::CONTENT_TYPE};
use axum::middleware::Next;
use axum::response::Response;

type AppResponse = Result<Response, AppErrors>;

const MAX_BODY_SIZE: usize = 1024;

pub async fn validate_headers(headers: HeaderMap, request: Request, next: Next) -> AppResponse {
    let allowed_content_type = "text/plain";
    let content_type = headers
        .get(CONTENT_TYPE)
        .ok_or(AppErrors::NoContentType)?
        .to_str()
        .map_err(|_| AppErrors::NoContentType)?;

    if !content_type.contains(allowed_content_type) {
        return Err(AppErrors::BadContentType(content_type.to_owned()));
    }

    Ok(next.run(request).await)
}

pub async fn validate_body_length(request: Request, next: Next) -> AppResponse {
    let (parts, body) = request.into_parts();
    let bytes = to_bytes(body, usize::MAX)
        .await
        .map_err(|_| AppErrors::InvalidBody)?;
    let new_req = Request::from_parts(parts, Body::from(bytes.clone()));

    if bytes.len() >= MAX_BODY_SIZE {
        return Err(AppErrors::BodyTooLarge(bytes.len()));
    }

    Ok(next.run(new_req).await)
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{
        Router,
        body::Body,
        http::{Method, Request, StatusCode, header::CONTENT_TYPE},
        middleware::from_fn,
        routing::post,
    };
    use tower::ServiceExt;

    // Dummy handler for testing
    async fn ok_handler() -> &'static str {
        "ok"
    }

    #[tokio::test]
    async fn test_validate_headers_accepts_valid_content_type() {
        let request = Request::builder()
            .method(Method::POST)
            .uri("/")
            .header(CONTENT_TYPE, "text/plain")
            .body(Body::empty())
            .unwrap();

        let app = Router::new()
            .route("/", post(ok_handler))
            .layer(from_fn(validate_headers));

        let response = app.oneshot(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_validate_headers_rejects_missing_content_type() {
        let request = Request::builder()
            .method(Method::POST)
            .uri("/")
            .body(Body::empty())
            .unwrap();

        let app = Router::new()
            .route("/", post(ok_handler))
            .layer(from_fn(validate_headers));

        let response = app.oneshot(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
    }

    #[tokio::test]
    async fn test_validate_headers_rejects_invalid_content_type() {
        let request = Request::builder()
            .method(Method::POST)
            .uri("/")
            .header(CONTENT_TYPE, "application/json")
            .body(Body::empty())
            .unwrap();

        let app = Router::new()
            .route("/", post(ok_handler))
            .layer(from_fn(validate_headers));

        let response = app.oneshot(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::UNSUPPORTED_MEDIA_TYPE);
    }

    #[tokio::test]
    async fn test_validate_body_length_accepts_small_body() {
        let body = "a".repeat(100);
        let request = Request::builder()
            .method(Method::POST)
            .uri("/")
            .body(Body::from(body))
            .unwrap();
        let app = Router::new()
            .route("/", post(ok_handler))
            .layer(from_fn(validate_body_length));
        let response = app.oneshot(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_validate_body_length_rejects_large_body() {
        let body = "a".repeat(2000);
        let request = Request::builder()
            .method(Method::POST)
            .uri("/")
            .body(Body::from(body))
            .unwrap();
        let app = Router::new()
            .route("/", post(ok_handler))
            .layer(from_fn(validate_body_length));
        let response = app.oneshot(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::PAYLOAD_TOO_LARGE);
    }
}
