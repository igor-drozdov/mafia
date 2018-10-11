defmodule Mafia.Chapters.Announcement do
  use Mafia.Chapter

  alias Mafia.Chapters.RoundEnds
  alias Mafia.Players.{Round, Player}
  alias Playground.Repo
  alias MafiaWeb.Endpoint

  import Ecto.Query

  @period Application.get_env(:playground, :period) |> Keyword.fetch!(:medium)

  defp handle_run(%{game_uuid: game_uuid, round_id: round_id, players: players}) do
    player = ostracize_deprecated_player(round_id)
    notify_leader(game_uuid, player)

    Process.send_after(self(), {:transition, players -- [player]}, @period)
  end

  def ostracize_deprecated_player(round_id) do
    {most_deprecated_player, _} =
      Player.by_status(round_id, :deprecated)
      |> group_by([p, pr, ps], [ps.player_round_id, p.id])
      |> order_by([p, pr, ps], desc: count(ps.id))
      |> limit(1)
      |> select([p, pr, ps], {p, count(ps.id)})
      |> Repo.one()

    Round.create_status(round_id, most_deprecated_player.id, :ostracized)

    most_deprecated_player
  end

  def notify_leader(game_uuid, player) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "city_wakes", %{players: [player]})
  end

  def handle_info({:transition, new_players}, %{game_uuid: game_uuid} = state) do
    RoundEnds.run(game_uuid, Map.put(state, :players, new_players))

    {:stop, :shutdown, state}
  end
end
