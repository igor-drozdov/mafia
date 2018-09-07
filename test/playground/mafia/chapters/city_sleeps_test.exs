defmodule Playground.Mafia.Chapters.CitySleepsTest do
  use PlaygroundWeb.ChannelCase

  alias Playground.Mafia.Chapters.CitySleeps

  import Playground.Factory

  describe "#notify_leader" do
    test "broadcast city sleeps" do
      game = insert(:game)
      @endpoint.subscribe("leader:current:#{game.id}")

      CitySleeps.notify_leader(game.id)

      assert_broadcast "play_audio", %{audio: "city_sleeps"}
    end
  end
end
