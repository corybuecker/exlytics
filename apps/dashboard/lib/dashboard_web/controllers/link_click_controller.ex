defmodule Exlytics.DashboardWeb.LinkClickController do
  @moduledoc false
  use Exlytics.DashboardWeb, :controller

  alias Exlytics.Dashboard.LinkClicks

  def index(conn, _params) do
    link_clicks = LinkClicks.list_link_clicks()
    render(conn, "index.json", link_clicks: link_clicks)
  end

  def show(conn, %{"id" => id}) do
    link_click = LinkClicks.get_link_click!(id)
    render(conn, "show.json", link_click: link_click)
  end
end
