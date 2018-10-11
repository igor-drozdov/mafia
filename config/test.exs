use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mafia, MafiaWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :mafia, Mafia.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "mafia_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :mafia, :period,
  short: 0,
  medium: 0,
  long: 0
