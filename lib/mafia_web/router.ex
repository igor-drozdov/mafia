defmodule MafiaWeb.Router do
  use MafiaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MafiaWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources "/games", GameController do
      resources("/players", PlayerController)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MafiaWeb do
  #   pipe_through :api
  # end
end
