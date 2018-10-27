defmodule Mafia.Chapters.VotingBegins do
  use Mafia.Chapter

  alias Mafia.Players.{Round, Player}
  alias Mafia.Repo
  alias Mafia.Chapters.Announcement
  alias MafiaWeb.Endpoint

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid, round_id: round_id, players: players} = state) do
    notify_players(game_uuid, round_id, players)

    {:noreply, Map.put(state, :voted_players, [])}
  end

  def handle_cast(
        {:choose_candidate, target_player_uuid, voted_player_uuid},
        %{voted_players: voted_players} = state
      ) do
    if voted_player_uuid in voted_players do
      {:noreply, state}
    else
      new_state = Map.put(state, :voted_players, [voted_player_uuid | voted_players])
      proceed_candidate_choosing(target_player_uuid, voted_player_uuid, new_state)
    end
  end

  def handle_cast(
        {:sync, player_uuid},
        %{
          game_uuid: game_uuid,
          round_id: round_id,
          players: players,
          voted_players: voted_players
        } = state
      ) do
    players = Enum.filter(players, &(&1.id == player_uuid))
    if player_uuid not in voted_players, do: notify_players(game_uuid, round_id, players)

    {:noreply, state}
  end

  def notify_players(game_uuid, round_id, players) do
    nominated_players =
      Player.by_status(round_id, :nominated)
      |> order_by([p], asc: p.inserted_at)
      |> Repo.all()

    Enum.each(players, fn player ->
      payload = %{players: List.delete(nominated_players, player)}

      Endpoint.broadcast(
        "followers:#{game_uuid}:#{player.id}",
        "candidates_received",
        payload
      )
    end)
  end

  def proceed_candidate_choosing(
        target_player_uuid,
        voted_player_uuid,
        %{game_uuid: game_uuid, round_id: round_id} = state
      ) do
    deprecate_player(round_id, target_player_uuid, voted_player_uuid)
    notify_player_chosen(game_uuid, voted_player_uuid)
    announce_results(game_uuid, state)
  end

  def deprecate_player(round_id, player_uuid, deprecated_by_uuid) do
    Round.create_status(round_id, player_uuid, :deprecated, deprecated_by_uuid)
  end

  def notify_player_chosen(game_uuid, current_player_uuid) do
    Endpoint.broadcast(
      "followers:#{game_uuid}:#{current_player_uuid}",
      "player_chosen",
      %{}
    )
  end

  def announce_results(
        game_uuid,
        %{players: players, voted_players: voted_players} = state
      )
      when length(players) == length(voted_players) do
    Announcement.run(game_uuid, Map.delete(state, :voted_players))

    {:stop, :shutdown, state}
  end

  def announce_results(_, state) do
    {:noreply, state}
  end
end
