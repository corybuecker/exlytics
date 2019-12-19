import Config

config :exlytics,
  firestore_database: System.get_env("FIRESTORE_DATABASE"),
  port: 8080
