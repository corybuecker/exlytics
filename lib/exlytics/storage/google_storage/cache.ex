defmodule Exlytics.Storage.GoogleStorage.Cache do
  @moduledoc false

  use GenServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_initial_state) do
    GenServer.start_link(Exlytics.Storage.GoogleStorage.Cache, [],
      name: Exlytics.Storage.GoogleStorage.Cache
    )
  end

  @impl true
  @spec init(any) :: {:ok, any}
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:flush, _from, state) do
    {:reply, state, []}
  end

  @impl true
  def handle_cast({:push, event}, state) do
    {:noreply, [event | state]}
  end
end
