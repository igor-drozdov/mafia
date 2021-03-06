defmodule Mafia.Chapters.MafiaSleepsTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.MafiaSleeps

  import Mafia.Factory

  describe "#notify_leader" do
    test "broadcast mafia sleeps" do
      game = insert(:game, state: :current)
      @endpoint.subscribe("leader:#{game.id}")

      MafiaSleeps.notify_leader(game.id)

      assert_broadcast("play_audio", %{audio: "mafia_sleeps"})
    end
  end
end
