defmodule Playground.Mafia.Chapters.RoundBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.{Chapters.CitySleeps, Chapters.DiscussionBegins, PlayerRound, Round}
  alias Playground.{Repo, Mafia}

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid, players: players} = state) do
    round = create_round(game_uuid, players)
    new_state = Map.put(state, :round_id, round.id)

    number_of_rounds =
      from(r in Round, where: [game_id: ^game_uuid], select: count(r.id))
      |> Repo.one

    case number_of_rounds do
      1 -> DiscussionBegins.run(game_uuid, new_state)
      _ -> CitySleeps.run(game_uuid, new_state)
    end

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
end
