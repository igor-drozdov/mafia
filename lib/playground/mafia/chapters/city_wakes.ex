defmodule Playground.Mafia.Chapters.CityWakes do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.DiscussionBegins

  defp handle_run(game_uuid) do
    DiscussionBegins.run(game_uuid)
  end
end
