defmodule Exlytics.Data do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Exlytics.Data.Repo, []}
    ]

    Supervisor.start_link(children, [{:strategy, :one_for_one}])
  end
end
