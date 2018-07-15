defmodule PlaygroundWeb.LeaderRoomChannel do
  use PlaygroundWeb, :channel

  alias Playground.Mafia
  alias Playground.Repo
  require IEx

  def join("rooms:leader:" <> id, _payload, socket) do
    game =
      Mafia.get_game!(id)
      |> Repo.preload(:players)

    {:ok, game, assign(socket, :game, game)}
  end
end
