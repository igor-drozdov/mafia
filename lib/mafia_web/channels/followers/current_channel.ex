defmodule MafiaWeb.Followers.CurrentChannel do
  use MafiaWeb, :channel

  alias Mafia.{Games, Repo}

  def join("followers:current:" <> ids, _payload, socket) do
    [game_uuid, player_uuid] = String.split(ids, ":")
    game = Games.get_game!(game_uuid) |> Repo.preload(:players)

    new_socket =
      socket
      |> assign(:game_uuid, game_uuid)
      |> assign(:player_uuid, player_uuid)

    {:ok, game, new_socket}
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
