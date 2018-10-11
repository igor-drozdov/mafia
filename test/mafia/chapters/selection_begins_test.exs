defmodule Mafia.Chapters.SelectionBeginsTest do
  use PlaygroundWeb.ChannelCase

  alias Mafia.Chapters.SelectionBegins

  import Playground.Factory

  describe "#notify_leader" do
    test "broadcast selection begins" do
      game = insert(:game)
      @endpoint.subscribe("leader:current:#{game.id}")

      SelectionBegins.notify_leader(game.id)

      assert_broadcast("selection_begins", %{})
    end
  end
end
