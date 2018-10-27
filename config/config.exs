# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mafia,
  ecto_repos: [Mafia.Repo]

# Configures the endpoint
config :mafia, MafiaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "alfAFmcEjAPGZz9EHxeGWHFSnHCSFlr9CzpmICKXRacsepBDO+9Mo1LiLp64NK5p",
  render_errors: [view: MafiaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mafia.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
