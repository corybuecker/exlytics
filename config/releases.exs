import Config

config :exlytics,
  host: System.get_env("HOST"),
  port: System.get_env("PORT"),
  redis: System.get_env("REDIS")
