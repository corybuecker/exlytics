import Config

config :exlytics,
  host: "localhost",
  port: "8080"

config :exlytics, Exlytics.Data.Repo,
  url: "ecto://exlytics:exlytics@localhost:5432/exlytics?ssl=false"
