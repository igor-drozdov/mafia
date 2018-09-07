defmodule Playground.Mafia.Chapters.CitySleeps do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Chapters.MafiaWakes
  alias PlaygroundWeb.Endpoint

  @period Application.get_env(:playground, :period) |> Keyword.fetch(:short)

  defp handle_run(%{game_uuid: game_uuid}) do
    notify_leader(game_uuid)
    wake_mafia()
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{audio: "city_sleeps"})
  end

  def wake_mafia do
    Process.send_after(self(), :transition, @period)
  end

  def handle_info(:transition, %{game_uuid: game_uuid} = state) do
    MafiaWakes.run(game_uuid, state)

    {:stop, :shutdown, state}
  end
end
