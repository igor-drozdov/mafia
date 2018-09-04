defmodule Playground.Mafia.Chapters.MafiaWakes do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.{Chapters.MafiaSleeps, Player, PlayerRound}
  alias Playground.Repo
  alias PlaygroundWeb.Endpoint

  import Ecto.Query

  def handle_run(%{game_uuid: game_uuid} = state) do
    {mafias, innocents} =
      Player.incity(game_uuid)
      |> Repo.all
      |> Enum.split_with(& &1.role == :mafia)

    notify_leader(game_uuid)
    notify_candidates_received(game_uuid, mafias, innocents)

    {:noreply, Map.put(state, :mafias, mafias)}
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{ audio: "mafia_wakes" })
  end

  def notify_candidates_received(game_uuid, mafias, innocents) do
    payload = %{
      players: Enum.map(innocents, &Map.take(&1, [:id, :name, :state]))
    }
    notify_mafia_players(game_uuid, mafias, "candidates_received", payload)
  end

  def handle_cast({:choose_candidate, player_uuid},
    %{game_uuid: game_uuid, round_id: round_id, mafias: mafias} = state) do

    runout_player(round_id, player_uuid)
    notify_mafia_players(game_uuid, mafias, "player_chosen")

    MafiaSleeps.run(game_uuid, state)

    {:stop, :shutdown, state}
  end

  def runout_player(round_id, player_uuid) do
    PlayerRound
    |> where(player_id: ^player_uuid, round_id: ^round_id)
    |> Repo.one()
    |> Ecto.build_assoc(:player_statuses, %{ type: :runout })
    |> Repo.insert()
  end

  def notify_mafia_players(game_uuid, mafias, msg, payload \\ %{}) do
    Enum.each mafias, fn mafia ->
      Endpoint.broadcast("followers:current:#{game_uuid}:#{mafia.id}", msg, payload)
    end
  end
end
