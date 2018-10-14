defmodule MafiaWeb.Followers.Channel do
  use MafiaWeb, :channel

  alias MafiaWeb.Endpoint
  alias Mafia.{Games, Repo}

  def join("followers:" <> ids, _payload, socket) do
    [game_uuid, player_uuid] = String.split(ids, ":")
    game = Games.get_game!(game_uuid) |> Repo.preload(:players)

    init(game, player_uuid, game.state)

    new_socket =
      socket
      |> assign(:game_uuid, game_uuid)
      |> assign(:player_uuid, player_uuid)

    {:ok, game, new_socket}
  end

  def init(game, player_uuid, :init) do
    player =
      game.players
      |> Enum.find(&(&1.id == player_uuid))
      |> Map.take([:id, :name, :state])

    Endpoint.broadcast("leader:#{game.id}", "follower_joined", player)

    if enough_players_connected?(game), do: handout_roles!(game)
  end

  def init(_, _, _) do
  end

  defp enough_players_connected?(game) do
    length(game.players) == game.total
  end

  defp handout_roles!(game) do
    Mafia.Chapters.HandoutRoles.run(game.id)
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

  defp current_data(%{game_uuid: game_uuid, player_uuid: current_player_uuid}) do
    {current_player_uuid, Mafia.Narrator.current(game_uuid)}
  end
end
