defmodule Playground.Mafia.Chapters.CitySleeps do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.MafiaSleeps

  defp handle_run(game_uuid) do
    MafiaSleeps.run(game_uuid)
  end
end