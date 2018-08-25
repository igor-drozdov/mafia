defmodule Playground.Mafia.Chapters.DiscussionEnds do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.Announcement

  defp handle_run(game_uuid) do
    Announcement.run(game_uuid)
  end
end
