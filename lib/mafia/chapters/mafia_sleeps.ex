defmodule Mafia.Chapters.MafiaSleeps do
  use Mafia.Chapter
  alias Mafia.Chapters.CityWakes
  alias MafiaWeb.Endpoint

  @period Application.get_env(:mafia, :period) |> Keyword.fetch!(:short)

  defp handle_run(%{game_uuid: game_uuid}) do
    notify_leader(game_uuid)
    Process.send_after(self(), :transition, @period)
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:#{game_uuid}", "play_audio", %{audio: "mafia_sleeps"})
  end

  def handle_info(:transition, %{game_uuid: game_uuid} = state) do
    CityWakes.run(game_uuid, state)

    {:stop, :shutdown, state}
  end
end
