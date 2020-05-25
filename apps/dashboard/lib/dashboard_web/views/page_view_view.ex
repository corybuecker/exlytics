defmodule Exlytics.DashboardWeb.PageViewView do
  use Exlytics.DashboardWeb, :view
  alias Exlytics.DashboardWeb.PageViewView

  def render("index.json", %{page_views: page_views}) do
    %{data: render_many(page_views, PageViewView, "page_view.json")}
  end

  def render("show.json", %{page_view: page_view}) do
    %{data: render_one(page_view, PageViewView, "page_view.json")}
  end

  def render("page_view.json", %{page_view: page_view}) do
    %{
      date: page_view |> elem(0) |> Date.to_iso8601(),
      count: page_view |> elem(1) |> Decimal.to_integer()
    }
  end
end
