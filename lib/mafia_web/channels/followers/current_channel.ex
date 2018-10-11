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
    %{game_uuid: game_uuid, player_uuid: current_player_uuid} = socket.assigns
    current_process = Mafia.Narrator.current(game_uuid)

    GenServer.cast(current_process, {:choose_candidate, target_player_uuid, current_player_uuid})

    {:noreply, socket}
  end
end