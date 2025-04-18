use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};

#[derive(Debug)]
pub enum AppErrors {
    NoContentType,
    BadContentType(String),
    BadEventData(String),
    InvalidBody,
    BodyTooLarge(usize),
}

impl IntoResponse for AppErrors {
    fn into_response(self) -> Response {
        match self {
            AppErrors::BadEventData(err) => (StatusCode::BAD_REQUEST, err).into_response(),
            AppErrors::NoContentType => {
                (StatusCode::BAD_REQUEST, "Missing Content-Type header").into_response()
            }
            AppErrors::BadContentType(val) => (
                StatusCode::UNSUPPORTED_MEDIA_TYPE,
                format!("Unsupported Content-Type: {}", val),
            )
                .into_response(),
            AppErrors::InvalidBody => {
                (StatusCode::BAD_REQUEST, "Invalid request body").into_response()
            }
            AppErrors::BodyTooLarge(size) => (
                StatusCode::PAYLOAD_TOO_LARGE,
                format!("Body too large: {} bytes (max 1024)", size),
            )
                .into_response(),
        }
    }
}

pub type AppResponse = Result<Response, AppErrors>;
