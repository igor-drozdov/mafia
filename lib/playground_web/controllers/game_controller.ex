defmodule PlaygroundWeb.GameController do
  use PlaygroundWeb, :controller

  alias Playground.Mafia
  alias Playground.Repo

  def create(conn, _params) do
    case Mafia.create_game() do
      {:ok, game} ->
        conn
        |> redirect(to: game_path(conn, :show, game))
      {:error, _changeset} ->
        conn
        |> redirect(to: page_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    game = Mafia.get_game!(id)
    player = player_from_session(conn, game)
    user_agents = get_req_header(conn, "user-agent")

    cond do
      player ->
        redirect(conn, to: game_player_path(conn, :show, game, player))
      Enum.any?(user_agents, & mobile?(&1)) ->
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
      nil -> nil
      player_id ->
        Repo.get_by(Mafia.Player, game_id: game.id, id: player_id)
    end
  end
end
