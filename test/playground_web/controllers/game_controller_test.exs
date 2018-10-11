defmodule MafiaWeb.GameControllerTest do
  use MafiaWeb.ConnCase

  alias Mafia.Games

  @create_attrs %{state: 0}
  @invalid_attrs %{state: "ab"}

  def fixture(:game) do
    {:ok, game} = Games.create_game(@create_attrs)
    game
  end

  describe "create game" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, game_path(conn, :create), game: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == game_path(conn, :show, id)

      conn = get(conn, game_path(conn, :show, id))
      assert html_response(conn, 200) =~ id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, game_path(conn, :create), game: @invalid_attrs)
      assert redirected_to(conn) == page_path(conn, :index)
    end
  end
end
