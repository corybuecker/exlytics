defmodule Exlytics.Storage.GoogleStorage do
  @moduledoc false
  require Logger

  def save(event) when is_map(event) do
    GenServer.cast(Exlytics.Storage.GoogleStorage.Cache, {:push, event})
  end

  def container do
    Application.get_env(:exlytics, :container, "bueckered-exlytics-development")
  end
end
