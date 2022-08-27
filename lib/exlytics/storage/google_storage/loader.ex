defmodule Exlytics.Storage.GoogleStorage.Loader do
  @moduledoc false

  alias Exlytics.Storage.GoogleStorage.Cache
  alias GoogleApi.Storage.V1.Api.Objects
  alias GoogleApi.Storage.V1.Connection
  alias GoogleApi.Storage.V1.Model.Object
  require Logger

  def load do
    GenServer.call(Cache, :flush) |> write_events()
  end

  defp write_events(events) when is_list(events) and length(events) > 0 do
    Logger.debug("received #{length(events)} events")

    with body <- events |> events_to_data(),
         {:ok, %{token: token}} <-
           Goth.Token.for_scope("https://www.googleapis.com/auth/devstorage.read_write"),
         connection <- Connection.new(token) do
      Objects.storage_objects_insert_iodata(
        connection,
        container(),
        "multipart",
        metadata(),
        body
      )
    end
  end

  defp write_events(_) do
    Logger.debug("no events, or invalid type, not writing")
  end

  defp metadata do
    %Object{
      name: "#{UUID.uuid4()}.json",
      contentType: "application/jsonl+json"
    }
  end

  defp events_to_data(events) when is_list(events) do
    events
    |> Enum.map_join("\n", fn event ->
      Jason.encode!(event)
    end)
  end

  defp container do
    Application.get_env(:exlytics, :storage).container()
  end
end
