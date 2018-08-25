defmodule Playground.Mafia.Chapters.RoundBegins do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.CitySleeps

  defp handle_run(game_uuid) do
    CitySleeps.run(game_uuid)
  end
end
