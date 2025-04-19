# Exlytics

Aggregate simple analytics events with HTTP via Rust and PostgreSQL.

## Dependencies

- Rust (latest stable version)
- PostgreSQL
- Docker (optional for containerized deployment)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/corybuecker/exlytics.git
cd exlytics
```

2. Set up the PostgreSQL database. You can use Docker to quickly start a PostgreSQL instance:

```bash
docker run \
   --name exlytics -d \
   -e POSTGRES_HOST_AUTH_METHOD=trust \
   -p 5434:5432 \
   -v $(pwd)/migrations/schema.sql:/docker-entrypoint-initdb.d/initialize.sql \
   -e POSTGRES_DB=exlytics \
   -e POSTGRES_USER=exlytics \
   postgres:17.4
```

3. Start the application:

```bash
cargo run --release
```

Once running, the application will expose an endpoint for collecting and querying analytics events. Note that the Content-Type header must be `text/plain` or `application/json` and the body must be valid JSON not longer than 1024 bytes.

## Example

Example of sending an analytics event (using curl):

```bash
curl -v -H "Content-Type: text/plain" \
   -d '{"event_name": "page_view", "timestamp": "2025-04-19T00:00:00Z"}' \
   http://localhost:8000/events
```

```plain
* Host localhost:8000 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:8000...
* connect to ::1 port 8000 from ::1 port 51910 failed: Connection refused
*   Trying 127.0.0.1:8000...
* Connected to localhost (127.0.0.1) port 8000
> POST /events HTTP/1.1
> Host: localhost:8000
> User-Agent: curl/8.7.1
> Accept: */*
> Content-Type: text/plain
> Content-Length: 64
> 
* upload completely sent off: 64 bytes
< HTTP/1.1 202 Accepted
< content-length: 0
< date: Sat, 19 Apr 2025 14:24:49 GMT
< 
* Connection #0 to host localhost left intact
```

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.