defmodule Playground.Mafia.Players.Chapters.PlayerSpeaksTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Players.Chapters.PlayerSpeaks

  import Playground.Factory

  describe "#notify_leader" do
    test "broadcast mafia sleeps" do
      game = insert(:game)
      player = insert(:player, game: game)
      @endpoint.subscribe("leader:current:#{game.id}")

      PlayerSpeaks.notify_leader(game.id, player)

      assert_broadcast("player_speaks", %{player: player})
    end
  end
end
