Web application for playing Mafia game offline. What does it mean? Please, check out the blog post about it for an explanation!

# Development

To start the Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Tests

To run unit and acceptance tests:

  * Install [`chromedriver`](http://chromedriver.chromium.org/getting-started)
  * Start tests with `mix test`

To run acceptance tests in demonstrantion mode (deliberately slower to view the behaviour of the app in a browser):

  * Start tests with `MIX_ENV=demo mix test --trace test/integration/smoke_test.exs`
