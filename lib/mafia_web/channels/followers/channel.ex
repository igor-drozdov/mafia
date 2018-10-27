defmodule MafiaWeb.Followers.Channel do
  use MafiaWeb, :channel

  alias MafiaWeb.Endpoint
  alias Mafia.{Games, Repo}

  def join("followers:" <> ids, _payload, socket) do
    [game_uuid, player_uuid] = String.split(ids, ":")
    game = Games.get_game!(game_uuid) |> Repo.preload(:players)

    new_socket =
      socket
      |> assign(:game, game)
      |> assign(:player_uuid, player_uuid)

    send(self(), :initialize)

    {:ok, game, new_socket}
  end

  def handle_info(:initialize, socket) do
    %{game: game, player_uuid: player_uuid} = socket.assigns
    init(game, player_uuid, game.state)

    {:noreply, socket}
  end

  def init(game, player_uuid, :init) do
    player =
      game.players
      |> Enum.find(&(&1.id == player_uuid))
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast("leader:#{game.id}", "follower_joined", player)

    if length(game.players) == game.total, do: Mafia.Chapters.HandoutRoles.run(game.id)
  end

  def init(game, player_uuid, _) do
    Mafia.Narrator.current(game.id)
    |> GenServer.cast({:sync, player_uuid})
  end

  def handle_in("choose_candidate", %{"player_id" => target_player_uuid}, socket) do
    {player_uuid, pid} = current_data(socket.assigns)
    GenServer.cast(pid, {:choose_candidate, target_player_uuid, player_uuid})

    {:noreply, socket}
  end

  def handle_in("speak", _payload, socket) do
    {_, pid} = current_data(socket.assigns)

    GenServer.cast(pid, :speak)

    {:noreply, socket}
  end

  defp current_data(%{game: game, player_uuid: current_player_uuid}) do
    {current_player_uuid, Mafia.Narrator.current(game.id)}
  end
end
