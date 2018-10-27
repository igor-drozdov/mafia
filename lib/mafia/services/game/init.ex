defmodule Mafia.Services.Game.Init do
  alias MafiaWeb.Endpoint

  def run(game, player_uuid, :init) do
    player =
      game.players
      |> Enum.find(&(&1.id == player_uuid))
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast("leader:#{game.id}", "follower_joined", player)

    if all_players_joined?(game), do: handout_roles!(game.id)
  end

  def run(game, player_uuid, _) do
    Mafia.Narrator.current(game.id)
    |> GenServer.cast({:sync, player_uuid})
  end

  def all_players_joined?(game) do
    length(game.players) == game.total
  end

  def handout_roles!(game_uuid) do
    Mafia.Chapters.HandoutRoles.run(game_uuid)
  end
end
