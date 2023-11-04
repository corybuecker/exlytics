defmodule Exlytics.Cache.Redis do
  @moduledoc false
  @behaviour Exlytics.Cache
  require Logger

  @impl Exlytics.Cache
  def save(event) when is_map(event) do
    Logger.debug(event |> inspect())

    event |> Jason.encode() |> maybe() |> save_encoded() |> maybe()
  end

  @impl Exlytics.Cache
  def flush do
    case exclusive_fetch() do
      {:ok, ["OK", "OK", "QUEUED", "QUEUED", [events, _]]} when is_list(events) -> {:ok, events}
      _ -> {:error, []}
    end
  end

  defp save_encoded({:ok, encoded}) do
    Redix.command(:exlytics, ["RPUSH", "exlytics", encoded])
  end

  defp save_encoded({:error, error}) when is_bitstring(error) do
    {:error, error}
  end

  defp maybe({:error, _}) do
    {:error, "could not save"}
  end

  defp maybe(anything) do
    anything
  end

  def exclusive_fetch do
    Redix.pipeline(:exlytics, [
      ["WATCH", "exlytics"],
      ["MULTI"],
      ["LRANGE", "exlytics", "0", "-1"],
      ["DEL", "exlytics"],
      ["EXEC"]
    ])
  end
end
