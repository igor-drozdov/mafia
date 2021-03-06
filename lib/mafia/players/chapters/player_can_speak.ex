defmodule Mafia.Players.Chapters.PlayerCanSpeak do
  use Mafia.Players.Chapter

  alias Mafia.Players.Chapters.{PlayerCanSpeak, PlayerSpeaks}
  alias Mafia.Chapters.SelectionBegins
  alias MafiaWeb.Endpoint

  def run(game_uuid, [], state) do
    SelectionBegins.run(game_uuid, Map.delete(state, [:player, :other_players]))
  end

  def run(game_uuid, [player | other_players], state) do
    new_state = Map.put(state, :other_players, other_players)

    PlayerCanSpeak.start(game_uuid, player, new_state)
    |> GenServer.cast(:run)
  end

  defp handle_run(%{game_uuid: game_uuid, player: player}) do
    notify_leader(game_uuid, player)
    notify_follower(game_uuid, player.id)
  end

  def handle_cast(:speak, %{game_uuid: game_uuid, player: player} = state) do
    PlayerSpeaks.run(game_uuid, player, state)

    {:stop, :shutdown, state}
  end

  def handle_cast({:sync, player_uuid}, %{game_uuid: game_uuid} = state) do
    notify_follower(game_uuid, player_uuid)

    {:noreply, state}
  end

  def notify_leader(game_uuid, player) do
    Endpoint.broadcast("leader:#{game_uuid}", "player_can_speak", %{player: player})
  end

  def notify_follower(game_uuid, player_uuid) do
    Endpoint.broadcast("followers:#{game_uuid}:#{player_uuid}", "player_can_speak", %{})
  end
end
