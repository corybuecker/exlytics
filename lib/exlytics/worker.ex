defmodule Exlytics.Worker do
  @moduledoc false

  alias Exlytics.Storage.GoogleStorage.Loader
  alias Exlytics.Worker
  use GenServer

  def start_link(_) do
    GenServer.start_link(Worker, [], name: Worker)
  end

  @impl true
  def init([]) do
    schedule_work()

    {:ok, []}
  end

  @impl true
  def handle_cast(:work, state) do
    Loader.load()
    {:noreply, state}
  end

  @impl true
  def handle_info(:work, state) do
    GenServer.cast(Worker, :work)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 2 * 60 * 60 * 1000)
  end
end
