use httparse::{Header, Request, Status, EMPTY_HEADER};
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

    runtime.block_on(async {
        let listener = TcpListener::bind("0.0.0.0:8000").await?;

        loop {
            if let Ok((stream, _)) = listener.accept().await {
                spawn(handle_request(stream));
            }
        }
    })
}

struct RequestError {}

impl From<httparse::Error> for RequestError {
    fn from(_error: httparse::Error) -> RequestError {
        RequestError {}
    }
}

async fn handle_request(mut stream: TcpStream) -> Result<(), RequestError> {
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
        let response = "HTTP/1.1 200 OK\n".as_bytes();
        let _ = stream.write_all(response).await;
    });
    let request_storage = spawn(async move { store_request(&buf).await });

    let (_r1, _r2) = join!(response_writer, request_storage);

    Ok(())
}

async fn store_request(buffer: &Vec<u8>) -> Result<(), RequestError> {
    let mut headers = [EMPTY_HEADER; 64];

    let request = Request::new(&mut headers).parse(buffer)?;

    let mut body: Option<usize> = None;
    if let Status::Complete(n) = request {
        body = Some(n);
    };

    if let Some(n) = body {
        if buffer.len() > n {
            let (_, body) = buffer.split_at(n);
            debug!("{:#?}", String::from_utf8(body.to_vec()).unwrap());
        }
    }

    let headers: Vec<httparse::Header> = headers
        .iter()
        .cloned()
        .filter(|h| h.value.len() > 0)
        .collect();

    debug!("{:#?}", headers);

    Ok(())
}
