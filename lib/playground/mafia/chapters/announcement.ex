defmodule Playground.Mafia.Chapters.Announcement do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.{PlayerStatus, PlayerRound, Player, Chapters.RoundEnds}
  alias Playground.Repo
  alias PlaygroundWeb.Endpoint

  import Ecto.Query

  defp handle_run(%{game_uuid: game_uuid, round_id: round_id, players: players} = state) do
    player = ostracize_deprecated_player(round_id)
    notify_leader(game_uuid, player)

    RoundEnds.run(game_uuid, Map.put(state, :players, players -- [player]))

    {:stop, :shutdown, state}
  end

  def ostracize_deprecated_player(round_id) do
    {most_deprecated_player, _} =
      Player.by_status(round_id, :deprecated)
      |> group_by([p, pr, ps], [ps.player_round_id, p.id])
      |> order_by([p, pr, ps], desc: count(ps.id))
      |> limit(1)
      |> select([p, pr, ps], {p, count(ps.id)})
      |> Repo.one()

    PlayerRound.create_status(round_id, most_deprecated_player.id, :ostracized)

    most_deprecated_player
  end

  def notify_leader(game_uuid, player) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "city_wakes", %{players: [player]})
  end
end
