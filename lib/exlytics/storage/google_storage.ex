defmodule Exlytics.Storage.GoogleStorage do
  @moduledoc false
  require Logger
  @behaviour Exlytics.Storage

  @impl Exlytics.Storage
  def save(event) when is_map(event) do
    GenServer.cast(Exlytics.Storage.GoogleStorage.Cache, {:push, event})
  end

  @impl Exlytics.Storage
  def container do
    Application.get_env(:exlytics, :container, "bueckered-exlytics-storage-development")
  end
end
