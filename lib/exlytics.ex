defmodule Exlytics do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children =
      [
        Plug.Cowboy.child_spec([
          {:scheme, :http},
          {:plug, Exlytics.Router},
          {:port, Application.fetch_env!(:exlytics, :port) |> String.to_integer()}
        ]),
        {Goth, name: Exlytics.Goth}
      ] ++ storage()

    Supervisor.start_link(children, [{:strategy, :one_for_one}])
  end

  defp storage do
    case Application.fetch_env!(:exlytics, :cache) do
      Exlytics.Utils.FakeCache ->
        []

      _ ->
        [
          {Redix, {Application.fetch_env!(:exlytics, :redis), [name: :exlytics]}},
          {Exlytics.Worker, []}
        ]
    end
  end
end
