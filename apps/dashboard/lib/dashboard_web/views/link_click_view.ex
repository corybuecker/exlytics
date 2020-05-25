defmodule Exlytics.DashboardWeb.LinkClickView do
  use Exlytics.DashboardWeb, :view
  alias Exlytics.DashboardWeb.LinkClickView

  def render("index.json", %{link_clicks: link_clicks}) do
    %{data: render_many(link_clicks, LinkClickView, "link_click.json")}
  end

  def render("show.json", %{link_click: link_click}) do
    %{data: render_one(link_click, LinkClickView, "link_click.json")}
  end

  def render("link_click.json", %{link_click: link_click}) do
    %{
      date: link_click |> elem(0) |> Date.to_iso8601(),
      count: link_click |> elem(1) |> Decimal.to_integer()
    }
  end
end
