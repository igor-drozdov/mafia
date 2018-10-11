defmodule Mafia.Chapters.InnocentsWin do
  use Mafia.Chapter

  defp handle_run(%{game_uuid: game_uuid} = state) do
    Mafia.Services.FinishGame.run(game_uuid, winner: :innocents)

    {:stop, :shutdown, state}
  end
end
