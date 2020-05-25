defmodule Exlytics.DashboardWeb.PageViewController do
  use Exlytics.DashboardWeb, :controller

  alias Exlytics.Dashboard.PageViews

  def index(conn, _params) do
    page_views = PageViews.list_page_views()
    render(conn, "index.json", page_views: page_views)
  end

  def show(conn, %{"id" => id}) do
    page_view = PageViews.get_page_view!(id)
    render(conn, "show.json", page_view: page_view)
  end
end
