defmodule Playground.Mafia.Chapters.CityWakes do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.DiscussionBegins
  alias PlaygroundWeb.Endpoint

  import Ecto.Query

  @period Application.get_env(:playground, :period) |> Keyword.fetch(:short)

  defp handle_run(%{game_uuid: game_uuid, round_id: round_id}) do
    notify_leader(game_uuid)
    send_night_results(game_uuid, round_id)

    Process.send_after(self(), :transition, @period)
  end

  def send_night_results(game_uuid, round_id) do
    players =
      Playground.Repo.get!(Playground.Mafia.Round, round_id)
      |> Ecto.assoc(:players)
      |> join(:inner, [p], ps in assoc(p, :player_statuses), ps.type == ^:ostracized)
      |> Playground.Repo.all

    Endpoint.broadcast("leader:current:#{game_uuid}", "city_wakes", %{ players: players })
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{ audio: "city_wakes" })
  end

  def handle_info(:transition, %{game_uuid: game_uuid} = state) do
    DiscussionBegins.run(game_uuid, state)

    {:stop, :shutdown, state}
  end
end
