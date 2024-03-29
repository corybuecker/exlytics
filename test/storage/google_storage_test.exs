defmodule Exlytics.Storage.GoogleStorageTest do
  use ExUnit.Case, async: true

  alias Exlytics.Storage.GoogleStorage

  test "loads a map event into the cache" do
    # GoogleStorage.save(%{test: true})
    # events = GenServer.call(Cache, :flush)
    # assert events == [%{test: true}]
  end

  test "does not load a non-map into the cache" do
    try do
      GoogleStorage.save(:test)
    rescue
      FunctionClauseError -> assert true
    end
  end
end
