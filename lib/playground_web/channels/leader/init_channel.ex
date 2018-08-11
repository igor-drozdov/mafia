defmodule PlaygroundWeb.Leader.InitChannel do
  use PlaygroundWeb, :channel

  alias Playground.Mafia
  alias Playground.Repo

  def join("rooms:leader:init" <> id, _payload, socket) do
    game =
      Mafia.get_game!(id)
      |> Repo.preload(:players)

    {:ok, game, assign(socket, :game, game)}
  end
end
