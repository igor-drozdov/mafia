defmodule MafiaWeb.Leader.ChannelTest do
  use MafiaWeb.ChannelCase

  alias MafiaWeb.Leader.Channel

  import Mafia.Factory

  test "ping replies with status ok" do
    game = insert(:game) |> Mafia.Repo.preload(:players)

    {:ok, ^game, socket} =
      socket("user_id", %{some: :assign})
      |> join(Channel, "leader:#{game.id}")

    assert socket.assigns.game == game
  end
end
