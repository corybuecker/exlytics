defmodule Exlytics do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec([
        {:scheme, :http},
        {:plug, Exlytics.Router},
        {:port, Application.fetch_env!(:exlytics, :port) |> String.to_integer()}
      ]),
      Mongo.child_spec([
        {:name, :mongo},
        {:database, Application.fetch_env!(:exlytics, :database)},
        {:pool_size, 4},
        {:seeds, [Application.fetch_env!(:exlytics, :mongo_connection)]}
      ])
    ]

    Supervisor.start_link(children, [{:strategy, :one_for_one}])
  end
end
