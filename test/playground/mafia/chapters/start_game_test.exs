defmodule Playground.Mafia.Chapters.StartGameTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Chapters.StartGame
  alias Playground.Mafia

  import Playground.Factory

  setup do
    game = insert(:game)
    {:ok, game: game}
  end

  describe "#notify_start_game" do
    test "broadcast game started", %{game: game} do
      game_uuid = game.id

      @endpoint.subscribe("leader:init:#{game_uuid}")
      StartGame.notify_leader(game_uuid)
      assert_broadcast("start_game", %{game_id: ^game_uuid, state: :current})
    end
  end

  describe "#notify_followers" do
    test "broadcast game started", %{game: game} do
      game_uuid = game.id

      player = insert(:player, game_id: game_uuid)
      player_uuid = player.id
      @endpoint.subscribe("followers:init:#{game_uuid}:#{player_uuid}")

      StartGame.notify_followers(game_uuid, [player])

      assert_broadcast("start_game", %{
        game_id: ^game_uuid,
        state: "current",
        player_id: ^player_uuid
      })
    end
  end

  describe "#update_game" do
    test "updates state of the game", %{game: game} do
      StartGame.update_game(game.id)
      assert Mafia.get_game!(game.id).state == :current
    end
  end
end
