defmodule Mafia.Chapters.CityWakesTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.CityWakes

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

      CityWakes.send_night_results(game_uuid, players)

      assert_broadcast("city_wakes", %{players: ^players})
    end
  end
end
