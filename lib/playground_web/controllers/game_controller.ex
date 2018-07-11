defmodule PlaygroundWeb.GameController do
  use PlaygroundWeb, :controller

  alias Playground.Mafia

  def create(conn, _params) do
    case Mafia.create_game(%{ "state" => "init" }) do
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
    player = player_from_session(conn)
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

  def player_from_session(conn) do
    player_id = get_session(conn, :player_id)
    player_id && Mafia.get_player!(player_id)
  end
end
