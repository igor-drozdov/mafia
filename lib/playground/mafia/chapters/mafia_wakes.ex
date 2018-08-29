defmodule Playground.Mafia.Chapters.MafiaWakes do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.{Chapters.MafiaSleeps, Player, PlayerRound}
  alias Playground.Repo
  alias PlaygroundWeb.Endpoint

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid}) do
    notify_mafia_wakes(game_uuid)
  end

  def notify_mafia_wakes(game_uuid) do
    incity_players = Player.incity(game_uuid)

    {mafias, innocents} = Enum.split_with(Repo.all(incity_players), & &1.role == :mafia)

    notify_leader(game_uuid)
    notify_mafia_players(game_uuid, mafias, innocents)
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{ audio: "mafia_wakes" })
  end

  def notify_mafia_players(game_uuid, mafias, innocents) do
    Enum.each mafias, fn mafia ->
      Endpoint.broadcast("followers:current:#{game_uuid}:#{mafia.id}",
        "candidates_received", %{
          players: Enum.map(innocents, &Map.take(&1, [:id, :name]))
        })
    end
  end

  def handle_cast({:choose_candidate, player_uuid},
    %{game_uuid: game_uuid, round_id: round_id} = state) do

    runout_player(round_id, player_uuid)

    MafiaSleeps.run(game_uuid, state)

    {:stop, :shutdown, state}
  end

  def runout_player(round_id, player_uuid) do
    PlayerRound
    |> where(player_id: ^player_uuid, round_id: ^round_id)
    |> Repo.one
    |> Ecto.build_assoc(:player_statuses, %{ type: :runout })
    |> Repo.insert
  end
end
