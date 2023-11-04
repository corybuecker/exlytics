# Exlytics

Exlytics is a very simple, privacy-focused tool to gather web analytics;
anything from page views to click-stream events. The events are cached in Redis
and flushed to Google Cloud Storage on a regular basis.

## Setup

1. Ensure that you have a running Redis instance and set the URL in
   `config/dev.exs`.
1. Create a Google Cloud Storage bucket and set the name in `config/dev.exs`.
1. Export a service account key and ensure that the SA has access to write to
   the GCS bucket.
1. Export an `GOOGLE_APPLICATION_CREDENTIALS` environment variable that points
   to the JSON key for the SA.

## Running

Run `iex -S mix` and the server will automatically start. Visit `localhost:8080`
and a generic event will be saved to Redis.

## Planned improvements

1. Replace Redis with Erlang ETS.
1. Replace the Google Service Account with Workload Identity.
