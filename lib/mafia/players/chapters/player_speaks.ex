defmodule Mafia.Players.Chapters.PlayerSpeaks do
  use Mafia.Players.Chapter

  alias Mafia.Players.Chapters.PlayerSpeaks
  alias Mafia.Chapters.SelectionBegins
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
    payload = %{player: player, elapsed: div(@period, 1000)}
    Endpoint.broadcast("leader:current:#{game_uuid}", "player_speaks", payload)
  end

  def handle_info({:transition, other_players}, %{game_uuid: game_uuid} = state) do
    PlayerSpeaks.run(game_uuid, other_players, state)

    {:stop, :shutdown, state}
  end
end
