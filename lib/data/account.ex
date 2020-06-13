defmodule Exlytics.Data.Account do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "accounts" do
    timestamps()
  end
end
