defmodule PlaygroundWeb.PlayerController do
  use PlaygroundWeb, :controller

  alias Playground.Mafia
  alias Playground.Mafia.Player

  def new(conn, %{"game_id" => game_id}) do
    game = Mafia.get_game!(game_id)
    changeset = Mafia.change_player(%Player{})

    render(conn, "new.html", changeset: changeset, game: game)
  end

  def create(conn, %{"player" => player_params, "game_id" => game_id}) do
    game = Mafia.get_game!(game_id)
    player_params_with_game = Map.put(player_params, "game_id", game_id)

    case Mafia.create_player(player_params_with_game) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> put_session(:game_id, game_id)
        |> put_session(:player_id, player.id)
        |> redirect(to: game_player_path(conn, :show, game, player))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, game: game)
    end
  end

  def show(conn, %{"id" => id, "game_id" => game_id}) do
    game = Mafia.get_game!(game_id)
    render(conn, "show.html", player_id: id, game: game)
  end
end
