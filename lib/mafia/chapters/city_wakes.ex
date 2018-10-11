defmodule Mafia.Chapters.CityWakes do
  use Mafia.Chapter
  alias Mafia.Chapters.DiscussionBegins
  alias PlaygroundWeb.Endpoint
  alias Mafia.{Repo, Games}

  import Ecto.Query

  @period Application.get_env(:playground, :period) |> Keyword.fetch!(:short)

  defp handle_run(%{game_uuid: game_uuid, round_id: round_id, players: players} = state) do
    ostricized_players =
      Repo.get!(Games.Round, round_id)
      |> Ecto.assoc(:players)
      |> join(:inner, [p], ps in assoc(p, :player_statuses), ps.type == ^:ostracized)
      |> Repo.all()

    notify_leader(game_uuid)
    send_night_results(game_uuid, ostricized_players)

    Process.send_after(self(), :transition, @period)

    {:noreply, Map.put(state, :players, players -- ostricized_players)}
  end

  def send_night_results(game_uuid, players) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "city_wakes", %{players: players})
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{audio: "city_wakes"})
  end

  def handle_info(:transition, %{game_uuid: game_uuid} = state) do
    DiscussionBegins.run(game_uuid, state)

    {:stop, :shutdown, state}
  end
end
