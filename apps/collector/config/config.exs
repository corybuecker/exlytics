import Config

config :collector,
  host: System.get_env("HOST"),
  port: System.get_env("PORT")

import_config "../../data/config/config.exs"
import_config "#{Mix.env()}.exs"
