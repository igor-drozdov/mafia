defmodule Mafia.Players.Chapters.PlayerSpeaks do
  use Mafia.Players.Chapter

  alias Mafia.Players.Chapters.{PlayerCanSpeak, PlayerSpeaks}
  alias MafiaWeb.Endpoint

  @period Application.get_env(:mafia, :period) |> Keyword.fetch!(:long)

  def run(game_uuid, player, state) do
    PlayerSpeaks.start(game_uuid, player, state)
    |> GenServer.cast(:run)
  end

  defp handle_run(%{game_uuid: game_uuid, player: player}) do
    notify_leader(game_uuid, player)
    notify_follower(game_uuid, player.id)

    Process.send_after(self(), :transition, @period)
  end

  def notify_leader(game_uuid, player) do
    payload = %{player: player, elapsed: @period}
    Endpoint.broadcast("leader:#{game_uuid}", "player_speaks", payload)
  end

  def notify_follower(game_uuid, player_uuid) do
    Endpoint.broadcast(
      "followers:#{game_uuid}:#{player_uuid}", "player_speaks", %{})
  end

  def handle_info(:transition,
    %{game_uuid: game_uuid, other_players: other_players} = state) do

    PlayerCanSpeak.run(game_uuid, other_players, state)

    {:stop, :shutdown, state}
  end
end
