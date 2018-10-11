defmodule Mafia.Players.Chapters.PlayerSpeaksTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Players.Chapters.PlayerSpeaks

  import Mafia.Factory

  describe "#notify_leader" do
    test "broadcast mafia sleeps" do
      game = insert(:game)
      player = insert(:player, game: game)
      @endpoint.subscribe("leader:current:#{game.id}")

      PlayerSpeaks.notify_leader(game.id, player)

      assert_broadcast("player_speaks", %{player: ^player})
    end
  end
end
