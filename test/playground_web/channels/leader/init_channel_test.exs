defmodule MafiaWeb.Leader.InitChannelTest do
  use MafiaWeb.ChannelCase

  alias MafiaWeb.Leader.InitChannel

  import Mafia.Factory

  test "ping replies with status ok" do
    game = insert(:game) |> Mafia.Repo.preload(:players)

    {:ok, ^game, socket} =
      socket("user_id", %{some: :assign})
      |> join(InitChannel, "leader:init:#{game.id}")

    assert socket.assigns.game == game
  end
end
