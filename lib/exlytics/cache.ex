defmodule Exlytics.Cache do
  @moduledoc false
  @callback save(Map.t()) :: {:ok, Map.t()} | {:error, String.t()}

  @callback flush() :: {:ok, List.t()} | {:error, List.t()}
end
