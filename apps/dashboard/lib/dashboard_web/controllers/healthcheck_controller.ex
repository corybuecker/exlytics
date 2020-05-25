defmodule Exlytics.DashboardWeb.HealthcheckController do
  @moduledoc false
  use Exlytics.DashboardWeb, :controller

  def index(conn, _params) do
    conn |> send_resp(200, "{\"database\":true, \"server\":true}")
  end
end
