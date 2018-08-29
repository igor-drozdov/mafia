defmodule Playground.Mafia.Chapters.MafiaSleeps do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.DiscussionBegins

  defp handle_run(game_uuid) do
    Process.send_after(self(), {:transition, game_uuid}, 1000)
  end

  def handle_info({:transition, game_uuid}, state) do
    DiscussionBegins.run(game_uuid)

    {:stop, :shutdown, state}
  end
end
