defmodule Exlytics.Storage.GoogleStorage.Loader do
  alias Exlytics.Storage.GoogleStorage.Cache
  alias GoogleApi.Storage.V1.Api.Objects
  alias GoogleApi.Storage.V1.Connection
  alias GoogleApi.Storage.V1.Model.Object

  require Logger

  def load do
    events = GenServer.call(Cache, :flush)

    cond do
      length(events) == 0 -> Logger.debug("no events, not writing")
      true -> write_events(events)
    end
  end

  defp write_events(events) do
    Logger.debug("received #{length(events)} events")

    with body <- events |> events_to_data(),
         {:ok, %{token: token}} <-
           Goth.Token.for_scope("https://www.googleapis.com/auth/devstorage.read_write"),
         connection <- Connection.new(token) do
      Objects.storage_objects_insert_iodata(
        connection,
        "bueckered-exlytics",
        "multipart",
        metadata(),
        body
      )
    end
  end

  defp metadata do
    %Object{
      name: "#{UUID.uuid4()}.json",
      contentType: "application/jsonl+json"
    }
  end

  defp events_to_data(events) when is_list(events) do
    events
    |> Enum.map(fn event ->
      Jason.encode!(event)
    end)
    |> Enum.join("\n")
  end
end
