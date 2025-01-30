use httparse::{Request, Status, EMPTY_HEADER};
use mongodb::bson::{doc, DateTime};
use mongodb::{Collection, Database};
use serde::{Deserialize, Serialize};
use serde_json::from_str;
use std::env;
use std::error::Error;
use tokio::io::AsyncWriteExt;
use tokio::net::TcpStream;
use tokio::signal::unix::{signal, SignalKind};
use tokio::{join, select};
use tokio::{net::TcpListener, runtime::Runtime, spawn};
use tracing::{error, Level};
use tracing_subscriber::FmtSubscriber;

fn main() -> Result<(), Box<dyn Error>> {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::DEBUG)
        .finish();
    let _ = tracing::subscriber::set_global_default(subscriber);

    let runtime = Runtime::new()?;
    let database_url = env::var("DATABASE_URL")?;

    runtime.block_on(async {
        select! {
         _ = run_listener(database_url) => {}
         _ = signal_listener() => {}
        }
    });

    Ok(())
}

struct RequestError {}

impl From<mongodb::error::Error> for RequestError {
    fn from(_error: mongodb::error::Error) -> RequestError {
        RequestError {}
    }
}

impl From<std::io::Error> for RequestError {
    fn from(_error: std::io::Error) -> RequestError {
        RequestError {}
    }
}
impl From<httparse::Error> for RequestError {
    fn from(_error: httparse::Error) -> RequestError {
        RequestError {}
    }
}

async fn signal_listener() -> Result<u8, Box<dyn Error>> {
    let mut signal = signal(SignalKind::terminate())?;

    signal.recv().await;
    Ok(0)
}

async fn run_listener(database_url: String) -> Result<(), Box<dyn Error>> {
    let database = mongodb::Client::with_uri_str(database_url).await?;
    let listener = TcpListener::bind("0.0.0.0:8001").await?;

    loop {
        if let Ok((stream, _)) = listener.accept().await {
            let database = database.database("exlytics");
            spawn(handle_request(stream, database));
        }
    }
}

async fn handle_request(mut stream: TcpStream, database: Database) -> Result<(), RequestError> {
    let mut request_buffer: Vec<u8> = Vec::with_capacity(128);

    loop {
        stream.readable().await?;

        let mut read_buffer = Vec::with_capacity(128);
        match stream.try_read_buf(&mut read_buffer) {
            Ok(_) => {
                request_buffer.append(&mut read_buffer);
            }
            Err(err) => {
                error!("{:#?}", err);
            }
        }

        let mut headers = [httparse::EMPTY_HEADER; 128];
        let mut req = httparse::Request::new(&mut headers);

        let res = req.parse(&request_buffer)?;

        if res.is_partial() {
            continue;
        }

        let Status::Complete(res) = res else {
            return Err(RequestError {});
        };

        let Some(content_length): Option<usize> = headers
            .iter()
            .find(|h| h.name.to_lowercase() == "content-length")
            .and_then(|h| Some(String::from_utf8(h.value.to_vec()).ok()?))
            .and_then(|h| Some(h.parse::<usize>().ok()?))
        else {
            return Err(RequestError {});
        };
        if request_buffer.len() < content_length + res {
            continue;
        }

        break;
    }

    let response_writer = spawn(async move {
        let response = "HTTP/1.1 200 OK\r\n\r\n".as_bytes();
        let _ = stream.write_all(response).await;
        let _ = stream.flush().await;
        let _ = stream.shutdown().await;
    });
    let request_storage = spawn(async move {
        let collection = database.collection::<Event>("events");
        store_request(&request_buffer, collection).await
    });

    let (_r1, _r2) = join!(response_writer, request_storage);

    Ok(())
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
