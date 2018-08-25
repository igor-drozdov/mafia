defmodule Playground.Mafia.Chapters.MafiaSleeps do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.MafiaWakes

  defp handle_run(game_uuid) do
    MafiaWakes.run(game_uuid)
  end
end
