defmodule Exlytics.Utils.FakeTimeAdapter do
  @moduledoc false

  def current_time do
    {:ok, time, _} = DateTime.from_iso8601("2000-01-01T00:00:00Z")
    time
  end
end
