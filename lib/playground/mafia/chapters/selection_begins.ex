defmodule Playground.Mafia.Chapters.SelectionBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Players.Chapters.PlayerChooses
  alias PlaygroundWeb.Endpoint

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    notify_leader(game_uuid)

    PlayerChooses.run(game_uuid, players, state)

    {:stop, :shutdown, state}
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "selection_begins", %{})
  end
end
