defmodule Mafia.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Mafia.Repo, []),
      supervisor(MafiaWeb.Endpoint, []),
      supervisor(Mafia.GamesSupervisor, []),
      worker(Registry, [[name: Mafia.Registry, keys: :unique]])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mafia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MafiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
