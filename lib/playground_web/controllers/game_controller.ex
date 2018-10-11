defmodule PlaygroundWeb.GameController do
  use PlaygroundWeb, :controller

  alias Mafia.{Games, Repo, GamesSupervisor, Players.Player}

  def create(conn, %{"game" => game_params}) do
    case Games.create_game(game_params) do
      {:ok, game} ->
        GamesSupervisor.start_child(game.id)

        conn
        |> redirect(to: game_path(conn, :show, game))

      {:error, _changeset} ->
        conn
        |> redirect(to: page_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    player = player_from_session(conn, game)
    user_agents = get_req_header(conn, "user-agent")

    cond do
      player ->
        redirect(conn, to: game_player_path(conn, :show, game, player))

      Enum.any?(user_agents, &mobile?(&1)) ->
        redirect(conn, to: game_player_path(conn, :new, game))

      true ->
        render(conn, "show.html", game: game)
    end
  end

  defp mobile?(user_agent) do
    Regex.match?(~r/Mobile|webOS/, user_agent)
  end

  def player_from_session(conn, game) do
    case get_session(conn, :player_id) do
      nil ->
        nil

      player_id ->
        Repo.get_by(Player, game_id: game.id, id: player_id)
    end
  end
end
