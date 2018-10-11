defmodule PlaygroundWeb.Followers.InitChannel do
  use PlaygroundWeb, :channel

  alias PlaygroundWeb.Endpoint
  alias Mafia.{Games, Repo}

  def join("followers:init:" <> ids, _payload, socket) do
    [game_id, player_id] = String.split(ids, ":")

    game = Games.get_game!(game_id) |> Repo.preload(:players)

    player =
      game.players
      |> Enum.find(&(&1.id == player_id))
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast("leader:init:#{game_id}", "follower_joined", player)

    if enough_players_connected?(game), do: handout_roles!(game)

    {:ok, socket}
  end

  defp enough_players_connected?(game) do
    length(game.players) == game.total
  end

  defp handout_roles!(game) do
    Mafia.Chapters.HandoutRoles.run(game.id)
  end
end
