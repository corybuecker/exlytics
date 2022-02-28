import Config

config :exlytics,
  host: "localhost",
  port: "8080"

config :exlytics,
  storage: Exlytics.Storage.GoogleStorage,
  container: "bueckered-exlytics-development"
