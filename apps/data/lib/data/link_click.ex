defmodule Exlytics.Data.LinkClick do
  @moduledoc false
  use Ecto.Schema

  @primary_key false
  schema "link_clicks" do
    field(:day, :utc_datetime_usec)
    field(:host, :string)
    field(:link, :string)
    field(:count, :integer)
  end
end
