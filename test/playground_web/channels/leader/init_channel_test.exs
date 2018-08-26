defmodule PlaygroundWeb.Leader.InitChannelTest do
  use PlaygroundWeb.ChannelCase

  alias PlaygroundWeb.Leader.InitChannel

  import Playground.Factory

  test "ping replies with status ok" do
    game = insert(:game) |> Playground.Repo.preload(:players)

    {:ok, ^game, socket} =
      socket("user_id", %{some: :assign})
      |> join(InitChannel, "leader:init:#{game.id}")

    assert socket.assigns.game == game
  end
end
