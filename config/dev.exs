import Config

config :exlytics,
  host: "localhost",
  port: "8080"

config :exlytics, Exlytics.Data.Repo, url: "ecto://postgres@localhost:5432/exlytics_dev?ssl=false"
