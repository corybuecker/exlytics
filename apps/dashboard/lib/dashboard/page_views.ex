defmodule Exlytics.Dashboard.PageViews do
  @moduledoc """
  The PageViews context.
  """

  import Ecto.Query, warn: false
  alias Exlytics.Data.Repo

  alias Exlytics.Data.PageView

  @doc """
  Returns the list of page_views.

  ## Examples

      iex> list_page_views()
      [%PageView{}, ...]

  """
  def list_page_views do
    Repo.all(
      from(u in PageView,
        where: is_nil(u.page) == false,
        order_by: u.day,
        select: {u.day, sum(u.count)},
        group_by: u.day
      )
    )
  end

  @doc """
  Gets a single page_view.

  Raises `Ecto.NoResultsError` if the Page view does not exist.

  ## Examples

      iex> get_page_view!(123)
      %PageView{}

      iex> get_page_view!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_view!(id), do: Repo.get!(PageView, id)
end
