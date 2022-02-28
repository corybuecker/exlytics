defmodule Exlytics.Storage.GoogleStorage.CacheTest do
  use ExUnit.Case, async: true

  alias Exlytics.Storage.GoogleStorage.Cache

  setup_all do
    Cache.start_link([])

    :ok
  end

  test "stores and retrieves an event" do
    GenServer.cast(Cache, {:push, :test})
    events = GenServer.call(Cache, :flush)
    assert events == [:test]
  end
end
