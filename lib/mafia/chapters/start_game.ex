defmodule Mafia.Chapters.StartGame do
  use Mafia.Chapter
  alias Mafia.Chapters.RoundBegins
  alias Mafia.{Repo, Players.Player, Games.Game}
  alias MafiaWeb.Endpoint

  import Ecto.Query

  @period Application.get_env(:mafia, :period) |> Keyword.fetch!(:medium)

  defp handle_run(%{game_uuid: game_uuid} = state) do
    players = Repo.all(Player.incity(game_uuid))

    notify_leader(game_uuid, players)
    start_round()

    {:noreply, Map.put(state, :players, players)}
  end

  def notify_leader(game_uuid, players) do
    payload = %{players: players}
    Endpoint.broadcast("leader:#{game_uuid}", "start_game", payload)
  end

  def notify_followers(game_uuid, players) do
    payload = %{players: players}

    players
    |> Enum.each(fn player ->
      Endpoint.broadcast("followers:#{game_uuid}:#{player.id}", "start_game", payload)
    end)
  end

  def start_round do
    Process.send_after(self(), :transition, @period)
  end

  def handle_info(:transition, %{game_uuid: game_uuid, players: players} = state) do
    notify_followers(game_uuid, players)
    update_game(game_uuid)

    RoundBegins.run(game_uuid, state)

    {:stop, :shutdown, state}
  end

  def update_game(game_uuid) do
    from(Game, where: [id: ^game_uuid])
    |> Repo.update_all(set: [state: :current])
  end
end
