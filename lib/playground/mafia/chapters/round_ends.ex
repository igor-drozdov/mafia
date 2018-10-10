defmodule Playground.Mafia.Chapters.RoundEnds do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Chapters.{InnocentsWin, MafiaWins, RoundBegins}

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    {mafias, innocents} = Enum.split_with(players, &(&1.role == :mafia))

    resolve_game(game_uuid, players, mafias, innocents)

    {:stop, :shutdown, state}
  end

  def resolve_game(game_uuid, _, mafias, _) when length(mafias) == 0 do
    InnocentsWin.run(game_uuid)
  end

  def resolve_game(game_uuid, _, mafias, innocents) when length(mafias) >= length(innocents) do
    MafiaWins.run(game_uuid)
  end

  def resolve_game(game_uuid, players, _, _) do
    RoundBegins.run(game_uuid, %{players: players})
  end
end
