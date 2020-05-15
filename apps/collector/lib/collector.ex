defmodule Exlytics.Collector do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec([
        {:scheme, :http},
        {:plug, Exlytics.Collector.Router},
        {:port, Application.fetch_env!(:collector, :port) |> String.to_integer()}
      ])
    ]

    Supervisor.start_link(children, [{:strategy, :one_for_one}])
  end
end
