defmodule MCT.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MCT.Repo,
      # Start the Telemetry supervisor
      MCTWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MCT.PubSub},
      # Start the Endpoint (http/https)
      MCTWeb.Endpoint,
      MCT.CachedSettings
      # Start a worker by calling: MCT.Worker.start_link(arg)
      # {MCT.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MCT.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MCTWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
