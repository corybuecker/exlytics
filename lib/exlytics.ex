defmodule Exlytics do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug: Exlytics.Router,
       options: [port: Application.fetch_env!(:exlytics, :port), ip: {0, 0, 0, 0}]}
    ]

    opts = [strategy: :one_for_one, name: Exlytics.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
