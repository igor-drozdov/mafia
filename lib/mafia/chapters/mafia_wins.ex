defmodule Mafia.Chapters.MafiaWins do
  use Mafia.Chapter

  alias Mafia.Services.Game

  defp handle_run(%{game_uuid: game_uuid} = state) do
    Game.Finish.run(game_uuid, winner: :mafia)

    {:stop, :shutdown, state}
  end
end
