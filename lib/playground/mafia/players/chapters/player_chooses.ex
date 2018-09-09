defmodule Playground.Mafia.Players.Chapters.PlayerChooses do
  use Playground.Mafia.Players.Chapter

  alias Playground.Mafia.Chapters.VotingBegins
  alias Playground.Mafia.Players.Chapters.PlayerChooses
  alias PlaygroundWeb.Endpoint
  alias Playground.Mafia.PlayerRound

  def run(game_uuid, [], state) do
    VotingBegins.run(game_uuid, Map.delete(state, :other_players))
  end

  def run(game_uuid, [player | other_players], state) do
    PlayerChooses.start(game_uuid, player, state)
    |> GenServer.cast({:run, other_players})
  end

  defp handle_run(
         other_players,
         %{game_uuid: game_uuid, player: player, players: players} = state
       ) do
    notify_leader(game_uuid, player)
    notify_player(game_uuid, player, players)

    {:noreply, Map.put(state, :other_players, other_players)}
  end

  def notify_leader(game_uuid, player) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "player_speaks", %{player: player})
  end

  def notify_player(game_uuid, player, players) do
    candidates = List.delete(players, player)

    Endpoint.broadcast("followers:current:#{game_uuid}:#{player.id}", "candidates_received", %{
      players: candidates
    })
  end

  def handle_cast(
        {:choose_candidate, player_uuid, nominated_by_uuid},
        %{game_uuid: game_uuid, round_id: round_id, other_players: other_players} = state
      ) do
    nominate_player(round_id, player_uuid, nominated_by_uuid)
    notify_player_chosen(game_uuid, nominated_by_uuid)

    PlayerChooses.run(game_uuid, other_players, state)

    {:stop, :shutdown, state}
  end

  def nominate_player(round_id, player_uuid, nominated_by_uuid) do
    PlayerRound.create_status(round_id, player_uuid, :nominated, nominated_by_uuid)
  end

  def notify_player_chosen(game_uuid, player_uuid) do
    Endpoint.broadcast("followers:current:#{game_uuid}:#{player_uuid}", "player_chosen", %{})
  end
end
