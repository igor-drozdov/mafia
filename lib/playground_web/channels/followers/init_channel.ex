defmodule PlaygroundWeb.Followers.InitChannel do
  use PlaygroundWeb, :channel

  alias PlaygroundWeb.Endpoint
  alias Playground.Mafia
  alias Playground.Repo

  def join("rooms:followers:init:" <> game_id, %{ "player_id" => player_id }, socket) do
    game =
      Mafia.get_game!(game_id)
      |> Repo.preload(:players)

    player =
      game.players
      |> Enum.find(& &1.id == player_id)
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast "rooms:leader:init:#{game_id}", "follower_joined", player

    {:ok, socket}
  end
end
