defmodule Playground.Mafia.Chapters.RoundBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.{Chapters.CitySleeps, Player, PlayerRound, Game}
  alias Playground.{Repo, Mafia}

  import Ecto.Query

  defp handle_run(game_uuid) do
    create_round(game_uuid)
    update_game(game_uuid)

    CitySleeps.run(game_uuid)
  end

  def create_round(game_uuid) do
    {:ok, round} = Mafia.create_round(%{game_id: game_uuid})

    incity_players =
      Player
      |> join(:left, [p], s in assoc(p, :player_statuses))
      |> where([p, s], p.game_id == ^game_uuid and (is_nil(s.player_round_id) or s.type != ^:runout))
      |> select([p], map(p, [:id]))
      |> Repo.all


    player_rounds =
      Enum.map incity_players, & %{
        round_id: round.id,
        player_id: &1.id,
        inserted_at: DateTime.utc_now,
        updated_at: DateTime.utc_now
      }

    Repo.insert_all(PlayerRound, player_rounds)
  end

  def update_game(game_uuid) do
    from(Game, where: [id: ^game_uuid])
    |> Repo.update_all([set: [state: :current]])
  end
end
