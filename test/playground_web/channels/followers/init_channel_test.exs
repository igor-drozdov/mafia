defmodule PlaygroundWeb.Followers.InitChannelTest do
  use PlaygroundWeb.ChannelCase

  alias PlaygroundWeb.Followers.InitChannel

  import Playground.Factory

  setup do
    game_uuid = insert(:game).id
    player = insert(:player, game_id: game_uuid)

    @endpoint.subscribe("leader:init:#{game_uuid}")

    {:ok, _, _} =
      socket("user_id", %{some: :assign})
      |> join(InitChannel, "followers:init:#{game_uuid}:#{player.id}")

    {:ok, player: player}
  end

  test "ping replies with status ok", %{player: player} do
    player_params = Map.take(player, [:id, :name, :state])
    assert_broadcast("follower_joined", ^player_params)
  end
end
