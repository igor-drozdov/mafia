defmodule Playground.Mafia.Chapters.StartGame do
  use Playground.Mafia.Chapter
  alias Playground.Mafia.{Player, Chapters.RoundBegins}
  alias Playground.Repo
  alias PlaygroundWeb.Endpoint

  @period Application.get_env(:playground, :period) |> Keyword.fetch(:medium)

  defp handle_run(%{game_uuid: game_uuid} = state) do
    players = Repo.all(Player.incity(game_uuid))

    notify_leader(game_uuid)
    start_round()

    {:noreply, Map.put(state, :players, players)}
  end

  def notify_leader(game_uuid) do
    payload = %{game_id: game_uuid, state: "current"}
    Endpoint.broadcast("leader:init:#{game_uuid}", "start_game", payload)
  end

  def notify_followers(game_uuid, players) do
    players
    |> Enum.each(fn player ->
      payload = %{
        game_id: game_uuid,
        state: "current",
        player_id: player.id
      }

      Endpoint.broadcast("followers:init:#{game_uuid}:#{player.id}", "start_game", payload)
    end)
  end

  def start_round do
    Process.send_after(self(), :transition, @period)
  end

  def handle_info(:transition, %{game_uuid: game_uuid, players: players} = state) do
    notify_followers(game_uuid, players)

    RoundBegins.run(game_uuid, state)

    {:stop, :shutdown, state}
  end
end
