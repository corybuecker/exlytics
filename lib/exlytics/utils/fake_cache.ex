defmodule Exlytics.Utils.FakeCache do
  @moduledoc false

  def save(event) do
    {:ok, event}
    send(self(), :event)
  end

  def flush do
    ["{}"]
  end
end
