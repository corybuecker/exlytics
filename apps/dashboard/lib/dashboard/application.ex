defmodule Exlytics.Dashboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Exlytics.DashboardWeb.Endpoint

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Exlytics.DashboardWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Exlytics.Dashboard.PubSub},
      # Start the Endpoint (http/https)
      Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exlytics.Dashboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
