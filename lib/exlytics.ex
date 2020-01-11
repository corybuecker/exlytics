defmodule Exlytics do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec([
        {:scheme, :http},
        {:plug, Exlytics.Router},
        {:port, Application.fetch_env!(:exlytics, :port)}
      ])
    ]

    Supervisor.start_link(children, [{:strategy, :one_for_one}])
  end
end
