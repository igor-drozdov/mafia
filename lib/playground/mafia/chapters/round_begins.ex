defmodule Playground.Mafia.Chapters.RoundBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.{Chapters.CitySleeps, PlayerRound, Game}
  alias Playground.{Repo, Mafia}

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    update_game(game_uuid)
    round = create_round(game_uuid, players)

    CitySleeps.run(game_uuid, Map.put(state, :round_id, round.id))

    {:stop, :shutdown, state}
  end

  def create_round(game_uuid, players) do
    {:ok, round} = Mafia.create_round(%{game_id: game_uuid})

    player_rounds =
      Enum.map(
        players,
        &%{
          round_id: round.id,
          player_id: &1.id,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      )

    Repo.insert_all(PlayerRound, player_rounds)

    round
  end

  def update_game(game_uuid) do
    from(Game, where: [id: ^game_uuid])
    |> Repo.update_all(set: [state: :current])
  end
end
