defmodule Playground.Mafia.Chapters.RoundBeginsTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Chapters.RoundBegins
  alias Playground.{Mafia, Repo}

  import Playground.Factory

  setup do
    game = insert(:game)

    {:ok, game: game}
  end

  describe "#create_round" do
    test "create rounds and player rounds", %{game: game} do
      game_uuid = game.id
      players = insert_list(7, :player, game_id: game_uuid) 
      runout_player_round = insert(:player_round, player: List.last(players))
      insert(:player_status, player_round: runout_player_round, type: :runout)

      RoundBegins.create_round(game_uuid)

      round = List.last(Repo.preload(Mafia.list_rounds(), [:game, :players]))
      round_players = players |> Enum.take(6) |> Enum.map(& &1.id) |> Enum.reverse

      assert round.game == game
      assert Enum.map(round.players, & &1.id) == round_players
    end
  end

  describe "#update_game" do
    test "updates state of the game", %{game: game} do
      RoundBegins.update_game(game.id)
      assert Mafia.get_game!(game.id).state == :current
    end
  end
end
