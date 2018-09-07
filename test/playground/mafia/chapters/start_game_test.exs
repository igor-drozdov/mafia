defmodule Playground.Mafia.Chapters.StartGameTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Chapters.StartGame

  import Playground.Factory

  setup do
    game = insert(:game)
    {:ok, game_uuid: game.id}
  end

  describe "#notify_start_game" do
    test "broadcast game started", %{game_uuid: game_uuid} do
      @endpoint.subscribe("leader:init:#{game_uuid}")
      StartGame.notify_leader(game_uuid)
      assert_broadcast "start_game", %{game_id: game_uuid, state: "current"}
    end
  end

  describe "#notify_followers" do
    test "broadcast game started", %{game_uuid: game_uuid} do
      player = insert(:player, game_id: game_uuid)
      player_uuid = player.id
      @endpoint.subscribe("followers:init:#{game_uuid}:#{player_uuid}")

      StartGame.notify_followers(game_uuid, [player])

      assert_broadcast "start_game", %{
        game_id: ^game_uuid, state: "current", player_id: ^player_uuid
      }
    end
  end
end
