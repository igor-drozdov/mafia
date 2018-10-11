defmodule Mafia.Chapters.RoundBeginsTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.RoundBegins
  alias Mafia.{Repo, Games}

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

      round = List.last(Repo.preload(Games.list_rounds(), [:game, :players]))
      round_players = players |> Enum.take(6) |> Enum.map(& &1.id)

      assert round.game == game
      assert Enum.map(round.players, & &1.id) == round_players
    end
  end
end
