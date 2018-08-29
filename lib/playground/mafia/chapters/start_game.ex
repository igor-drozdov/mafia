defmodule Playground.Mafia.Chapters.StartGame do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.{Player, Chapters.RoundBegins}
  alias Playground.Repo
  alias PlaygroundWeb.Endpoint

  defp handle_run(%{game_uuid: game_uuid}) do
    notify_leader(game_uuid)
  end

  def notify_leader(game_uuid) do
    payload = %{game_id: game_uuid, state: "current"}
    Endpoint.broadcast("leader:init:#{game_uuid}", "start_game", payload)
  end

  def notify_followers(game_uuid) do
    Player.incity(game_uuid)
    |> Repo.all
    |> Enum.each(fn player ->
         payload = %{
           game_id: game_uuid, state: "current", player_id: player.id
         }
         Endpoint.broadcast(
           "followers:init:#{game_uuid}:#{player.id}", "start_game", payload)
       end)
  end

  def start_round do
    Process.send_after(self(), :transition, 5000)
  end

  def handle_info(:transition, %{game_uuid: game_uuid} = state) do
    notify_followers(game_uuid)

    RoundBegins.run(game_uuid)

    {:stop, :shutdown, state}
  end
end
