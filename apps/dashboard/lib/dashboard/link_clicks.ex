defmodule Exlytics.Dashboard.LinkClicks do
  @moduledoc """
  The LinkClicks context.
  """

  import Ecto.Query, warn: false
  alias Exlytics.Data.Repo

  alias Exlytics.Data.LinkClick

  def list_link_clicks do
    Repo.all(
      from(u in LinkClick,
        where: is_nil(u.link) == false,
        order_by: u.day,
        select: {u.day, sum(u.count)},
        group_by: u.day
      )
    )
  end
end
