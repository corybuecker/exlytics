use std::error::Error;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
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

    if let Ok(request) = String::from_utf8(buf) {
        debug!("{}", request);
    }

    let _ = stream
        .write_all("HTTP/1.1 200 OK\n".to_string().as_bytes())
        .await;

    Ok(())
}
