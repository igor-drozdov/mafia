defmodule Playground.Mafia.Players.Chapters.PlayerSpeaks do
  use Playground.Mafia.Players.Chapter

  alias Playground.Mafia.Players.Chapters.PlayerSpeaks
  alias Playground.Mafia.Chapters.SelectionBegins
  alias PlaygroundWeb.Endpoint

  @period Application.get_env(:playground, :period) |> Keyword.fetch!(:long)

  def run(game_uuid, [], state) do
    SelectionBegins.run(game_uuid, Map.delete(state, :player))
  end

  def run(game_uuid, [player | other_players], state) do
    PlayerSpeaks.start(game_uuid, player, state)
    |> GenServer.cast({:run, other_players})
  end

  defp handle_run(other_players, %{game_uuid: game_uuid, player: player}) do
    notify_leader(game_uuid, player)

    Process.send_after(self(), {:transition, other_players}, @period)
  end

  def notify_leader(game_uuid, player) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "player_speaks", %{player: player})
  end

  def handle_info({:transition, other_players}, %{game_uuid: game_uuid} = state) do
    PlayerSpeaks.run(game_uuid, other_players, state)

    {:stop, :shutdown, state}
  end
end
