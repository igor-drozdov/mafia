defmodule MafiaWeb.PageController do
  use MafiaWeb, :controller

  alias Mafia.{Games, Games.Game}

  def index(conn, _params) do
    game_id = get_session(conn, :game_id)
    game = game_id && Games.get_game(game_id)
    changeset = Games.change_game(%Game{})

    render(conn, "index.html", game: game, changeset: changeset)
  end
end
