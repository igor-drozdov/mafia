defmodule MafiaWeb.Followers.ChannelTest do
  use MafiaWeb.ChannelCase

  alias MafiaWeb.Followers.Channel

  import Mafia.Factory

  setup do
    game_uuid = insert(:game).id
    player = insert(:player, game_id: game_uuid)

    @endpoint.subscribe("leader:#{game_uuid}")

    {:ok, _, _} =
      socket(MafiaWeb.UserSocket, "user_id", %{some: :assign})
      |> join(Channel, "followers:#{game_uuid}:#{player.id}")

    {:ok, player: player}
  end

  test "ping replies with status ok", %{player: player} do
    player_params = Map.take(player, [:id, :name, :state])
    assert_broadcast("follower_joined", ^player_params)
  end
end
