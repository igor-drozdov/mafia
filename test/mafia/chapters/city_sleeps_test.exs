defmodule Mafia.Chapters.CitySleepsTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.CitySleeps

  import Mafia.Factory

  describe "#notify_leader" do
    test "broadcast city sleeps" do
      game = insert(:game)
      @endpoint.subscribe("leader:current:#{game.id}")

      CitySleeps.notify_leader(game.id)

      assert_broadcast("play_audio", %{audio: "city_sleeps"})
    end
  end
end
