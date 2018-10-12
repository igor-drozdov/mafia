defmodule Mafia.Players.Chapters.PlayerChooses do
  use Mafia.Players.Chapter

  alias Mafia.Chapters.VotingBegins
  alias Mafia.Players.Chapters.PlayerChooses
  alias Mafia.Players.Round
  alias MafiaWeb.Endpoint

  def run(game_uuid, [], state) do
    VotingBegins.run(game_uuid, Map.delete(state, [:player, :other_players]))
  end

  def run(game_uuid, [player | other_players], state) do
    new_state = Map.put(state, :other_players, other_players)

    PlayerChooses.start(game_uuid, player, new_state)
    |> GenServer.cast(:run)
  end

  defp handle_run(%{game_uuid: game_uuid, player: player, players: players}) do
    notify_leader(game_uuid, player)
    notify_player(game_uuid, player, players)
  end

  def notify_leader(game_uuid, player) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "player_chooses", %{player: player})
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
    Round.create_status(round_id, player_uuid, :nominated, nominated_by_uuid)
  end

  def notify_player_chosen(game_uuid, player_uuid) do
    Endpoint.broadcast("followers:current:#{game_uuid}:#{player_uuid}", "player_chosen", %{})
  end
end
