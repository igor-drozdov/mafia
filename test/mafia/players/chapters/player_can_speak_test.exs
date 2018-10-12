defmodule Mafia.Players.Chapters.PlayerCanSpeakTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Players.Chapters.PlayerCanSpeak

  import Mafia.Factory

  setup do
    game = insert(:game)
    player = insert(:player, game: game)

    {:ok, game: game, player: player}
  end

  describe "#notify_leader" do
    test "broadcast player can speak", %{game: game, player: player} do
      @endpoint.subscribe("leader:current:#{game.id}")

      PlayerCanSpeak.notify_leader(game.id, player)

      assert_broadcast("player_can_speak", %{player: ^player})
    end
  end

  describe "#notify_follower" do
    test "broadcast can speak", %{game: game, player: player} do
      @endpoint.subscribe("followers:current:#{game.id}:#{player.id}")

      PlayerCanSpeak.notify_follower(game.id, player.id)

      assert_broadcast("player_can_speak", %{})
    end
  end
end
