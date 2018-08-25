defmodule Playground.Mafia.Players.Chapters.PlayerSpeaks do
  use Playground.Mafia.Players.Chapter

  alias Playground.Mafia.Players.Chapters.PlayerSpeaks
  alias Playground.Mafia.Chapters.SelectionBegins
  alias Playground.Mafia.Chapters.DiscussionEnds

  def run(game_uuid, []) do
    SelectionBegins.run(game_uuid)
  end

  def run(game_uuid, [player_uuid | other_players]) do
    PlayerSpeaks.start(game_uuid, player_uuid)
    |> GenServer.cast({:run, other_players})
  end

  defp handle_run(game_uuid, player_uuid, other_players) do
    PlayerSpeaks.run(game_uuid, other_players)
  end
end
