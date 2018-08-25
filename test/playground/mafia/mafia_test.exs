defmodule Playground.MafiaTest do
  use Playground.DataCase

  alias Playground.Mafia

  describe "games" do
    alias Playground.Mafia.Game

    @valid_attrs %{state: 0}
    @update_attrs %{state: 1}
    @invalid_attrs %{state: "state"}

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
      assert game.state == :init
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mafia.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Mafia.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.state == :current
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

  describe "players" do
    alias Playground.Mafia.Player

    @valid_attrs %{name: "some name", state: 0}
    @update_attrs %{name: "some updated name", state: 1}
    @invalid_attrs %{name: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Mafia.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Mafia.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Mafia.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Mafia.create_player(@valid_attrs)
      assert player.name == "some name"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mafia.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, player} = Mafia.update_player(player, @update_attrs)
      assert %Player{} = player
      assert player.name == "some updated name"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Mafia.update_player(player, @invalid_attrs)
      assert player == Mafia.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Mafia.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Mafia.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Mafia.change_player(player)
    end
  end
end
