import Config

config :exlytics,
  database: System.get_env("DATABASE"),
  host: System.get_env("HOST"),
  mongo_connection: System.get_env("MONGO_CONNECTION"),
  port: System.get_env("PORT")

import_config "#{Mix.env()}.exs"
