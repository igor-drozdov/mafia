defmodule Playground.MafiaTest do
  use Playground.DataCase

  alias Playground.Mafia

  describe "games" do
    alias Playground.Mafia.Game

    @valid_attrs %{state: "some state"}
    @update_attrs %{state: "some updated state"}
    @invalid_attrs %{state: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Mafia.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Mafia.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Mafia.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Mafia.create_game(@valid_attrs)
      assert game.state == "some state"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mafia.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Mafia.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.state == "some updated state"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Mafia.update_game(game, @invalid_attrs)
      assert game == Mafia.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Mafia.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Mafia.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Mafia.change_game(game)
    end
  end
end
