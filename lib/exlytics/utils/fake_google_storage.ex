defmodule Exlytics.Utils.FakeGoogleStorage do
  @moduledoc false
  require Logger
  @behaviour Exlytics.Storage

  @impl Exlytics.Storage
  def save(event) when is_map(event) do
    send(self(), :event)
    :ok
  end

  @impl Exlytics.Storage
  def container do
    Application.get_env(:exlytics, :container, "fake")
  end
end
