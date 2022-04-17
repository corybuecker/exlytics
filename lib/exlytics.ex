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
        Scheduler
      ] ++
        storage_engine()

    Supervisor.start_link(children, [{:strategy, :one_for_one}])
  end

  defp storage_engine do
    case Application.get_env(:exlytics, :storage) do
      Exlytics.Storage.GoogleStorage ->
        [Exlytics.Storage.GoogleStorage.Cache]

      Exlytics.Storage.Postgresql ->
        [Exlytics.Storage.Postgresql.Repo]
    end
  end
end
