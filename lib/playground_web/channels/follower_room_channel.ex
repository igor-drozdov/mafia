defmodule PlaygroundWeb.FollowerRoomChannel do
  use PlaygroundWeb, :channel

  alias PlaygroundWeb.Endpoint
  alias Playground.Mafia

  def join("rooms:followers:" <> game_id, %{ "player_id" => player_id }, socket) do
    player =
      Mafia.get_player!(player_id)
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast "rooms:leader:#{game_id}", "follower_joined", player

    {:ok, socket}
  end
end
