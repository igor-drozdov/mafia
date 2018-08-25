defmodule Playground.Mafia.Players.Chapters.PlayerChooses do
  use Playground.Mafia.Players.Chapter

  alias Playground.Mafia.Chapters.VotingBegins
  alias Playground.Mafia.Players.Chapters.PlayerChooses

  def run(game_uuid, []) do
    VotingBegins.run(game_uuid)
  end

  def run(game_uuid, [player_uuid | other_players]) do
    PlayerChooses.start(game_uuid, player_uuid)
    |> GenServer.cast({:run, other_players})
  end

  defp handle_run(game_uuid, player_uuid, other_players) do
    PlayerChooses.run(game_uuid, other_players)
  end
end
