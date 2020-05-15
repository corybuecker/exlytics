defmodule ExlyticsTest do
  use ExUnit.Case
  doctest Exlytics

  test "greets the world" do
    assert Exlytics.Collector.hello() == :world
  end
end
