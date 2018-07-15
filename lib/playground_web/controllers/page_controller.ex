defmodule PlaygroundWeb.PageController do
  use PlaygroundWeb, :controller

  alias Playground.Mafia

  require IEx

  def index(conn, _params) do
    game_id = get_session(conn, :game_id)
    game = game_id && Mafia.get_game(game_id)

    render conn, "index.html", game: game
  end
end
