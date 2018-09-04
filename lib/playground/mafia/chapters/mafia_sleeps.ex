defmodule Playground.Mafia.Chapters.MafiaSleeps do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.Chapters.CityWakes
  alias PlaygroundWeb.Endpoint

  defp handle_run(%{game_uuid: game_uuid}) do
    notify_leader(game_uuid)
    Process.send_after(self(), :transition, 5000)
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:current:#{game_uuid}", "play_audio", %{ audio: "mafia_sleeps" })
  end

  def handle_info(:transition, %{game_uuid: game_uuid} = state) do
    CityWakes.run(game_uuid, state)

    {:stop, :shutdown, state}
  end
end
