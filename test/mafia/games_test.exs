defmodule Mafia.GamesTest do
  use Mafia.DataCase

  alias Mafia.Games

  describe "games" do
    alias Mafia.Games.Game

    @valid_attrs %{state: 0}
    @update_attrs %{state: 1}
    @invalid_attrs %{state: "state"}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Games.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Games.create_game(@valid_attrs)
      assert game.state == :init
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Games.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.state == :current
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
      assert game == Games.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end

  describe "rounds" do
    alias Mafia.Games.Round
    alias Mafia.Repo

    import Mafia.Factory

    @update_attrs %{}
    @invalid_attrs %{game_id: nil}

    setup do
      round = insert(:round)
      {:ok, round: round}
    end

    test "list_rounds/0 returns all rounds", %{round: round} do
      assert Repo.preload(Games.list_rounds(), :game) == [round]
    end

    test "get_round!/1 returns the round with given id", %{round: round} do
      assert Repo.preload(Games.get_round!(round.id), :game) == round
    end

    test "create_round/1 with valid data creates a round" do
      assert {:ok, %Round{}} = Games.create_round(%{game_id: insert(:game).id})
    end

    test "create_round/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_round(@invalid_attrs)
    end

    test "update_round/2 with valid data updates the round", %{round: round} do
      assert {:ok, round} = Games.update_round(round, @update_attrs)
      assert %Round{} = round
    end

    test "update_round/2 with invalid data returns error changeset", %{round: round} do
      assert {:error, %Ecto.Changeset{}} = Games.update_round(round, @invalid_attrs)
      assert round == Repo.preload(Games.get_round!(round.id), :game)
    end

    test "delete_round/1 deletes the round", %{round: round} do
      assert {:ok, %Round{}} = Games.delete_round(round)
      assert_raise Ecto.NoResultsError, fn -> Games.get_round!(round.id) end
    end

    test "change_round/1 returns a round changeset", %{round: round} do
      assert %Ecto.Changeset{} = Games.change_round(round)
    end
  end

  describe "winners" do
    alias Mafia.Games.Winner

    @valid_attrs %{state: :innocents}
    @update_attrs %{state: :mafia}
    @invalid_attrs %{state: nil}

    def winner_fixture(attrs \\ %{}) do
      {:ok, winner} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Games.create_winner()

      winner
    end

    test "list_winners/0 returns all winners" do
      winner = winner_fixture()
      assert Games.list_winners() == [winner]
    end

    test "get_winner!/1 returns the winner with given id" do
      winner = winner_fixture()
      assert Games.get_winner!(winner.id) == winner
    end

    test "create_winner/1 with valid data creates a winner" do
      assert {:ok, %Winner{} = winner} = Games.create_winner(@valid_attrs)
      assert winner.state == :innocents
    end

    test "create_winner/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_winner(@invalid_attrs)
    end

    test "update_winner/2 with valid data updates the winner" do
      winner = winner_fixture()
      assert {:ok, winner} = Games.update_winner(winner, @update_attrs)
      assert %Winner{} = winner
      assert winner.state == :mafia
    end

    test "update_winner/2 with invalid data returns error changeset" do
      winner = winner_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_winner(winner, @invalid_attrs)
      assert winner == Games.get_winner!(winner.id)
    end

    test "delete_winner/1 deletes the winner" do
      winner = winner_fixture()
      assert {:ok, %Winner{}} = Games.delete_winner(winner)
      assert_raise Ecto.NoResultsError, fn -> Games.get_winner!(winner.id) end
    end

    test "change_winner/1 returns a winner changeset" do
      winner = winner_fixture()
      assert %Ecto.Changeset{} = Games.change_winner(winner)
    end
  end
end
