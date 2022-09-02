defmodule Exlytics.Storage.GoogleStorage.Loader do
  @moduledoc false

  alias GoogleApi.Storage.V1.Api.Objects
  alias GoogleApi.Storage.V1.Connection
  alias GoogleApi.Storage.V1.Model.Object
  require Logger

  def load do
    Application.fetch_env!(:exlytics, :cache).flush() |> write_events() |> resave_failed_events()
  end

  defp write_events({:ok, events}) when is_list(events) and length(events) > 0 do
    Logger.debug("received #{length(events)} events")

    with body <- events |> events_to_data(),
         %{token: token} <- Goth.fetch!(Exlytics.Goth),
         connection <- Connection.new(token) do
      case Objects.storage_objects_insert_iodata(
             connection,
             container(),
             "multipart",
             metadata(),
             body
           ) do
        {:error, error} ->
          Logger.error(error |> inspect)
          {:error, events}

        _ ->
          {:ok, []}
      end
    else
      error ->
        Logger.error(error |> inspect)
        {:error, events}
    end
  end

  defp write_events(anything) do
    Logger.debug(anything |> inspect())
    Logger.info("no events, or invalid type, not writing")
  end

  defp resave_failed_events({:error, events}) do
    events
    |> Enum.each(fn event ->
      event |> Jason.decode!() |> Application.get_env(:exlytics, :cache).save()
    end)
  end

  defp resave_failed_events(_) do
    {:ok, []}
  end

  defp metadata do
    %Object{
      name: "#{UUID.uuid4()}.json",
      contentType: "application/jsonl+json"
    }
  end

  defp events_to_data(events) when is_list(events) do
    events |> Enum.join("\n")
  end

  defp container do
    Application.get_env(:exlytics, :storage).container()
  end
end
