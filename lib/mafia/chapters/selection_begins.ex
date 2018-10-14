defmodule Mafia.Chapters.SelectionBegins do
  use Mafia.Chapter

  alias Mafia.Players.Chapters.PlayerChooses
  alias MafiaWeb.Endpoint

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    notify_leader(game_uuid)

    PlayerChooses.run(game_uuid, players, state)

    {:stop, :shutdown, state}
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:#{game_uuid}", "selection_begins", %{})
  end
end
