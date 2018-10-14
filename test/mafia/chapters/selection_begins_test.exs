defmodule Mafia.Chapters.SelectionBeginsTest do
  use MafiaWeb.ChannelCase

  alias Mafia.Chapters.SelectionBegins

  import Mafia.Factory

  describe "#notify_leader" do
    test "broadcast selection begins" do
      game = insert(:game, state: :current)
      @endpoint.subscribe("leader:#{game.id}")

      SelectionBegins.notify_leader(game.id)

      assert_broadcast("selection_begins", %{})
    end
  end
end
