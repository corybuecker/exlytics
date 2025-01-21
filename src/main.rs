use httparse::{Header, Request, Status, EMPTY_HEADER};
use mongodb::bson::{doc, DateTime};
use mongodb::{Collection, Database};
use serde::{Deserialize, Serialize};
use serde_json::from_str;
use std::env;
use std::error::Error;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::join;
use tokio::net::TcpStream;
use tokio::{net::TcpListener, runtime::Runtime, spawn};
use tracing::{debug, Level};
use tracing_subscriber::FmtSubscriber;

fn main() -> Result<(), Box<dyn Error>> {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::DEBUG)
        .finish();
    let _ = tracing::subscriber::set_global_default(subscriber);

    let runtime = Runtime::new()?;
    let database_url = env::var("DATABASE_URL")?;

    runtime.block_on(async {
        let database = mongodb::Client::with_uri_str(database_url).await?;
        let listener = TcpListener::bind("0.0.0.0:8000").await?;

        loop {
            if let Ok((stream, _)) = listener.accept().await {
                let database = database.database("exlytics");
                spawn(handle_request(stream, database));
            }
        }
    })
}

struct RequestError {}

impl From<mongodb::error::Error> for RequestError {
    fn from(_error: mongodb::error::Error) -> RequestError {
        RequestError {}
    }
}

impl From<httparse::Error> for RequestError {
    fn from(_error: httparse::Error) -> RequestError {
        RequestError {}
    }
}

async fn handle_request(mut stream: TcpStream, database: Database) -> Result<(), RequestError> {
    let mut buf = Vec::with_capacity(256);

    loop {
        match stream.read_buf(&mut buf).await {
            Ok(0) => break,
            Ok(n) => {
                if n < 256 {
                    break;
                }
                continue;
            }
            Err(_) => return Err(RequestError {}),
        }
    }

    let response_writer = spawn(async move {
        let response = "HTTP/1.1 204 No Content\r\n\r\n".as_bytes();
        let _ = stream.write_all(response).await;
        let _ = stream.flush().await;
        let _ = stream.shutdown().await;
    });
    let request_storage = spawn(async move {
        let collection = database.collection::<Event>("events");
        store_request(&buf, collection).await
    });

    let (_r1, _r2) = join!(response_writer, request_storage);

    Ok(())
}

fn extract_header_value(headers: &Vec<Header>, name: &str) -> Option<String> {
    if let Some(header) = headers.iter().find(|h| h.name == name) {
        let Ok(value) = String::from_utf8(header.value.to_vec()) else {
            return None;
        };
        return Some(value);
    }

    None
}

async fn store_request(
    buffer: &Vec<u8>,
    collection: Collection<Event>,
) -> Result<(), RequestError> {
    let mut headers = [EMPTY_HEADER; 64];
    let mut request = Request::new(&mut headers);

    let mut body: Option<usize> = None;
    if let Status::Complete(n) = request.parse(buffer)? {
        body = Some(n);
    };

    let mut payload: Option<Payload> = None;
    if let Some(n) = body {
        if buffer.len() > n {
            let (_, body) = buffer.split_at(n);
            if let Ok(body) = String::from_utf8(body.to_vec()) {
                if let Ok(p) = from_str::<Payload>(&body) {
                    payload = Some(p);
                }
            }
        }
    }

    let _headers: Vec<httparse::Header> = request
        .headers
        .iter()
        .cloned()
        .filter(|h| h.value.len() > 0)
        .collect();

    if let Some(payload) = payload {
        collection
            .insert_one(Event {
                ts: DateTime::now(),
                host: payload.host,
                path: payload.path,
                method: payload.method,
                event: payload.event,
            })
            .await?;
    }
    Ok(())
}

#[derive(Deserialize, Debug)]
struct Payload {
    host: String,
    method: Option<String>,
    path: Option<String>,
    event: Option<String>,
}

#[derive(Serialize)]
struct Event {
    ts: DateTime,
    host: String,
    method: Option<String>,
    path: Option<String>,
    event: Option<String>,
}
