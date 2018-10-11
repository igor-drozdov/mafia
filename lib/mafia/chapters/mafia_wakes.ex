defmodule Mafia.Chapters.MafiaWakes do
  use Mafia.Chapter

  alias Mafia.{Chapters.MafiaSleeps, Players.Round}
  alias MafiaWeb.Endpoint

  def handle_run(%{game_uuid: game_uuid, players: players} = state) do
    {mafias, innocents} = Enum.split_with(players, &(&1.role == :mafia))

    notify_leader(game_uuid)
    notify_candidates_received(game_uuid, mafias, innocents)

    {:noreply, Map.put(state, :mafias, mafias)}
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{audio: "mafia_wakes"})
  end

  def notify_candidates_received(game_uuid, mafias, innocents) do
    payload = %{
      players: Enum.map(innocents, &Map.take(&1, [:id, :name, :state]))
    }

    notify_mafia_players(game_uuid, mafias, "candidates_received", payload)
  end

  def handle_cast(
        {:choose_candidate, target_player_uuid, _},
        %{game_uuid: game_uuid, round_id: round_id, mafias: mafias} = state
      ) do
    ostracize_player(round_id, target_player_uuid)
    notify_mafia_players(game_uuid, mafias, "player_chosen")

    MafiaSleeps.run(game_uuid, state)

    {:stop, :shutdown, Map.delete(state, :mafias)}
  end

  def ostracize_player(round_id, player_uuid) do
    Round.create_status(round_id, player_uuid, :ostracized)
  end

  def notify_mafia_players(game_uuid, mafias, msg, payload \\ %{}) do
    Enum.each(mafias, fn mafia ->
      Endpoint.broadcast("followers:current:#{game_uuid}:#{mafia.id}", msg, payload)
    end)
  end
end
