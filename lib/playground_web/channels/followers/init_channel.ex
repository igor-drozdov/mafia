defmodule PlaygroundWeb.Followers.InitChannel do
  use PlaygroundWeb, :channel
  import Ecto.Query

  alias PlaygroundWeb.Endpoint
  alias Playground.Mafia

  def join("rooms:followers:init:" <> game_id, %{ "player_id" => player_id }, socket) do
    game = Mafia.get_game!(game_id) |> preload(:players)

    player =
      game.players
      |> Enum.find & &1.id == player_id
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast "rooms:leader:#{game_id}", "follower_joined", player

    {:ok, socket}
  end
end
