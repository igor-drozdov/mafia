defmodule Mafia.Chapters.DiscussionBegins do
  use Mafia.Chapter

  alias Mafia.Players.Chapters.PlayerCanSpeak

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    PlayerCanSpeak.run(game_uuid, players, Map.put(state, :players, players))

    {:stop, :shutdown, state}
  end
end
