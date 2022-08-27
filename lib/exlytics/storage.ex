defmodule Exlytics.Storage do
  @moduledoc false

  @callback save(Map.t()) :: :ok
  @callback container() :: String.t()
end
