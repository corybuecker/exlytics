FROM rust:1.84.0-slim AS builder
RUN mkdir /app
WORKDIR /app
COPY Cargo.toml Cargo.lock /app
COPY src /app/src
RUN cargo build --release

FROM rust:1.84.0-slim
COPY --from=builder /app/target/release/exlytics /app/exlytics
RUN chown 1000:1000 /app/exlytics
RUN chmod 700 /app/exlytics
USER 1000
CMD ["/app/exlytics"]
