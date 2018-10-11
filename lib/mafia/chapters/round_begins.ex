defmodule Mafia.Chapters.RoundBegins do
  use Mafia.Chapter

  alias Mafia.Chapters.{CitySleeps, DiscussionBegins}
  alias Mafia.{Players, Round, Repo, Games}

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    round = create_round(game_uuid, players)
    new_state = Map.put(state, :round_id, round.id)

    number_of_rounds =
      from(r in Round, where: [game_id: ^game_uuid], select: count(r.id))
      |> Repo.one()

    case number_of_rounds do
      1 -> DiscussionBegins.run(game_uuid, new_state)
      _ -> CitySleeps.run(game_uuid, new_state)
    end

    {:stop, :shutdown, state}
  end

  def create_round(game_uuid, players) do
    {:ok, round} = Games.create_round(%{game_id: game_uuid})

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

    Repo.insert_all(Players.Round, player_rounds)

    round
  end
end
