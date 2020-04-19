import Config

config :exlytics,
  host: "localhost",
  port: "8080"

config :exlytics, Exlytics.Repo, url: "ecto://postgres:password@localhost:5432/exlytics_dev"
