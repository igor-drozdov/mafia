defmodule Playground.Mafia.Chapters.CityWakesTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Chapters.CityWakes

  import Playground.Factory

  setup do
    game = insert(:game)
    @endpoint.subscribe("leader:current:#{game.id}")

    {:ok, game_uuid: game.id}
  end

  describe "#notify_leader" do
    test "broadcast mafia sleeps", %{game_uuid: game_uuid} do
      CityWakes.notify_leader(game_uuid)

      assert_broadcast("play_audio", %{audio: "city_wakes"})
    end
  end

  describe "#send_night_results" do
    test "broadcast night results", %{game_uuid: game_uuid} do
      players = insert_list(3, :player, game_id: game_uuid)
      ostracized_player = List.last(players)
      player_round = insert(:player_round, player: ostracized_player)
      insert(:player_status, player_round: player_round, type: :ostracized)

      CityWakes.send_night_results(game_uuid, player_round.round_id)

      assert_broadcast("city_wakes", %{players: [^ostracized_player]})
    end
  end
end
