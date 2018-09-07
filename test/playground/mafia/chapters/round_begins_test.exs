defmodule Playground.Mafia.Chapters.RoundBeginsTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Chapters.RoundBegins
  alias Playground.{Mafia, Repo}

  import Playground.Factory

  describe "#create_round" do
    test "create rounds and player rounds" do
      player_status =
        insert(:player_status, type: :ostracized)
        |> Repo.preload(player_round: [player: :game])

      game = player_status.player_round.player.game
      game_uuid = game.id
      players = insert_list(6, :player, game_id: game_uuid)

      RoundBegins.create_round(game_uuid, players)

      round = List.last(Repo.preload(Mafia.list_rounds(), [:game, :players]))
      round_players = players |> Enum.take(6) |> Enum.map(& &1.id)

      assert round.game == game
      assert Enum.map(round.players, & &1.id) == round_players
    end
  end

  describe "#update_game" do
    test "updates state of the game" do
      game = insert(:game)
      RoundBegins.update_game(game.id)
      assert Mafia.get_game!(game.id).state == :current
    end
  end
end
