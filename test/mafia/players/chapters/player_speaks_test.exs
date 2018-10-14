defmodule Mafia.Players.Chapters.PlayerSpeaksTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Players.Chapters.PlayerSpeaks

  import Mafia.Factory

  setup do
    game = insert(:game, state: :current)
    player = insert(:player, game: game)

    {:ok, game: game, player: player}
  end

  describe "#notify_leader" do
    test "broadcast player can speak", %{game: game, player: player} do
      @endpoint.subscribe("leader:#{game.id}")

      PlayerSpeaks.notify_leader(game.id, player)

      assert_broadcast("player_speaks", %{player: ^player})
    end
  end

  describe "#notify_follower" do
    test "broadcast can speak", %{game: game, player: player} do
      @endpoint.subscribe("followers:#{game.id}:#{player.id}")

      PlayerSpeaks.notify_follower(game.id, player.id)

      assert_broadcast("player_speaks", %{})
    end
  end
end
