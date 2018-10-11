defmodule Playground.Mafia.Chapters.VotingBegins do
  use Playground.Mafia.Chapter

  alias Mafia.Players.{Round, Player}
  alias Mafia.Repo
  alias Playground.Mafia.Chapters.Announcement
  alias PlaygroundWeb.Endpoint

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid, round_id: round_id, players: players} = state) do
    notify_players(game_uuid, round_id, players)

    {:noreply, Map.put(state, :number_of_voted_players, 0)}
  end

  def notify_players(game_uuid, round_id, players) do
    nominated_players =
      Player.by_status(round_id, :nominated)
      |> order_by([p], asc: p.inserted_at)
      |> Repo.all()

    Enum.each(players, fn player ->
      payload = %{players: List.delete(nominated_players, player)}

      Endpoint.broadcast(
        "followers:current:#{game_uuid}:#{player.id}",
        "candidates_received",
        payload
      )
    end)
  end

  def handle_cast(
        {:choose_candidate, target_player_uuid, deprecated_by_uuid},
        %{
          game_uuid: game_uuid,
          round_id: round_id,
          players: players,
          number_of_voted_players: number_of_voted_players
        } = state
      ) do
    deprecate_player(round_id, target_player_uuid, deprecated_by_uuid)
    notify_player_chosen(game_uuid, deprecated_by_uuid)

    if all_players_voted?(players, number_of_voted_players),
      do: announce_results(game_uuid, state),
      else: {:noreply, Map.put(state, :number_of_voted_players, number_of_voted_players + 1)}
  end

  def deprecate_player(round_id, player_uuid, deprecated_by_uuid) do
    PlayerRound.create_status(round_id, player_uuid, :deprecated, deprecated_by_uuid)
  end

  def notify_player_chosen(game_uuid, current_player_uuid) do
    Endpoint.broadcast(
      "followers:current:#{game_uuid}:#{current_player_uuid}",
      "player_chosen",
      %{}
    )
  end

  def all_players_voted?(players, number_of_voted_players) do
    length(players) == number_of_voted_players + 1
  end

  def announce_results(game_uuid, state) do
    Announcement.run(game_uuid, Map.delete(state, :number_of_voted_players))

    {:stop, :shutdown, state}
  end
end
