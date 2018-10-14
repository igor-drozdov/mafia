defmodule Mafia.Chapters.StartGameTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.StartGame
  alias Mafia.Games

  import Mafia.Factory

  setup do
    game = insert(:game)
    {:ok, game: game}
  end

  describe "#notify_start_game" do
    test "broadcast game started", %{game: game} do
      game_uuid = game.id

      @endpoint.subscribe("leader:#{game_uuid}")
      StartGame.notify_leader(game_uuid, [])
      assert_broadcast("start_game", %{players: []})
    end
  end

  describe "#notify_followers" do
    test "broadcast game started", %{game: game} do
      game_uuid = game.id

      player = insert(:player, game_id: game_uuid)
      player_uuid = player.id
      @endpoint.subscribe("followers:#{game_uuid}:#{player_uuid}")

      StartGame.notify_followers(game_uuid, [player])

      assert_broadcast("start_game", %{players: [^player]})
    end
  end

  describe "#update_game" do
    test "updates state of the game", %{game: game} do
      StartGame.update_game(game.id)
      assert Games.get_game!(game.id).state == :current
    end
  end
end
