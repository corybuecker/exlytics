defmodule Exlytics.Data.PageView do
  use Ecto.Schema

  @primary_key false
  schema "page_views" do
    field(:day, :utc_datetime_usec)
    field(:host, :string)
    field(:page, :string)
    field(:count, :integer)
  end
end
