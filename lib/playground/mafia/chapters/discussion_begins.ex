defmodule Playground.Mafia.Chapters.DiscussionBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Players.Chapters.PlayerSpeaks

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    PlayerSpeaks.run(game_uuid, players, Map.put(state, :players, players))

    {:stop, :shutdown, state}
  end
end
