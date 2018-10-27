defmodule Mafia.Chapters.MafiaWakes do
  use Mafia.Chapter

  alias Mafia.{Chapters.MafiaSleeps, Players.Round}
  alias MafiaWeb.Endpoint

  def handle_run(%{game_uuid: game_uuid, players: players} = state) do
    {mafias, innocents} = Enum.split_with(players, &(&1.role == :mafia))

    new_state =
      state
      |> Map.put(:mafias, mafias)
      |> Map.put(:innocents, innocents)

    notify_leader(game_uuid)
    notify_candidates_received(game_uuid, mafias, innocents)

    {:noreply, new_state}
  end

  def handle_cast(
        {:sync, player_uuid},
        %{game_uuid: game_uuid, mafias: mafias, innocents: innocents} = state
      ) do
    players = Enum.filter(mafias, &(&1.id == player_uuid))
    notify_candidates_received(game_uuid, players, innocents)

    {:noreply, state}
  end

  def handle_cast(
        {:choose_candidate, target_player_uuid, _},
        %{game_uuid: game_uuid, round_id: round_id, mafias: mafias} = state
      ) do
    ostracize_player(round_id, target_player_uuid)
    notify_players(game_uuid, mafias, "player_chosen")

    MafiaSleeps.run(game_uuid, state)

    {:stop, :shutdown, Map.drop(state, [:mafias, :innocents])}
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:#{game_uuid}", "play_audio", %{audio: "mafia_wakes"})
  end

  def notify_candidates_received(game_uuid, players, innocents) do
    payload = %{
      players: Enum.map(innocents, &Map.take(&1, [:id, :name, :state]))
    }

    notify_players(game_uuid, players, "candidates_received", payload)
  end

  def notify_players(game_uuid, players, msg, payload \\ %{}) do
    Enum.each(players, fn player ->
      Endpoint.broadcast("followers:#{game_uuid}:#{player.id}", msg, payload)
    end)
  end

  def ostracize_player(round_id, player_uuid) do
    Round.create_status(round_id, player_uuid, :ostracized)
  end
end
