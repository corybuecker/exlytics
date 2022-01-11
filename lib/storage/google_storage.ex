defmodule Exlytics.Storage.GoogleStorage do
  require Logger

  def save(event) when is_map(event) do
    GenServer.cast(Exlytics.Storage.GoogleStorage.Cache, {:push, event})
  end
end
