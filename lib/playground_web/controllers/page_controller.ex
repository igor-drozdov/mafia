defmodule PlaygroundWeb.PageController do
  use PlaygroundWeb, :controller

  alias Playground.Mafia
  alias Playground.Mafia.Game

  def index(conn, _params) do
    game_id = get_session(conn, :game_id)
    game = game_id && Mafia.get_game(game_id)
    changeset = Mafia.change_game(%Game{})

    render(conn, "index.html", game: game, changeset: changeset)
  end
end
