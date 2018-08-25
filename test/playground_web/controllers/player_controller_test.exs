defmodule PlaygroundWeb.PlayerControllerTest do
  use PlaygroundWeb.ConnCase

  import Playground.Factory

  @create_attrs %{name: "some name"}
  @invalid_attrs %{name: nil}

  setup do
    {:ok, game: insert(:game)}
  end

  describe "new player" do
    test "renders form", %{conn: conn, game: game} do
      conn = get conn, game_player_path(conn, :new, game)
      assert html_response(conn, 200) =~ "Connect to the Game"
    end
  end

  describe "create player" do
    test "redirects to show when data is valid", %{conn: conn, game: game} do
      conn = post conn, game_player_path(conn, :create, game), player: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == game_player_path(conn, :show, game, id)

      conn = get conn, game_player_path(conn, :show, game, id)
      assert html_response(conn, 200) =~ id
    end

    test "renders errors when data is invalid", %{conn: conn, game: game} do
      conn = post conn, game_player_path(conn, :create, game), player: @invalid_attrs
      assert html_response(conn, 200) =~ "Connect to the Game"
    end
  end
end
