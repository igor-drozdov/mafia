use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mafia, MafiaWeb.Endpoint,
  http: [port: 4001],
  server: true

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
  short: 100,
  medium: 100,
  long: 100

config :hound, driver: "chrome_driver"

config :mafia, :socket_host, "ws://localhost:4001/socket/websocket"
