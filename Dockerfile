FROM rust@sha256:7b65306dd21304f48c22be08d6a3e41001eef738b3bd3a5da51119c802321883 AS builder
RUN mkdir -p /app/src
WORKDIR /app
COPY Cargo.toml Cargo.lock /app
RUN echo "fn main(){}" > /app/src/main.rs
RUN cargo build --release
COPY src /app/src
RUN touch /app/src/main.rs
RUN cargo build --release

FROM debian@sha256:00cd074b40c4d99ff0c24540bdde0533ca3791edcdac0de36d6b9fb3260d89e2
COPY --from=builder /app/target/release/exlytics /app/exlytics
RUN chown 1000:1000 /app/exlytics
RUN chmod 700 /app/exlytics
USER 1000
CMD ["/app/exlytics"]
