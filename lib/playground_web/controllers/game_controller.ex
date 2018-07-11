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
    user_agent =
      get_req_header(conn, "user-agent")
      |> List.first

    render(conn, "show.html",
           game: game, user_agent: user_agent)
  end
end
