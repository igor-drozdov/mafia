defmodule PlaygroundWeb.Followers.CurrentChannel do
  use PlaygroundWeb, :channel

  alias PlaygroundWeb.Endpoint
  alias Playground.{Mafia, Repo}
  alias Playground.Mafia.Chapters.MafiaWakes

  def join("followers:current:" <> ids, _payload, socket) do
    [game_id, player_id] = String.split(ids, ":")
    game = Mafia.get_game!(game_id) |> Repo.preload(:players)

    {:ok, game, assign(socket, :game, game)}
  end

  def handle_in("choose_candidate", %{"player_id" => player_id}, socket) do
    GenServer.cast(MafiaWakes.via(socket.assigns.game.id), {:choose_candidate, player_id})

    {:noreply, socket}
  end
end
