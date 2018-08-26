defmodule PlaygroundWeb.Leader.InitChannel do
  use PlaygroundWeb, :channel

  alias Playground.{Mafia, Repo}

  def join("leader:init:" <> id, _payload, socket) do
    game =
      Mafia.get_game!(id)
      |> Repo.preload(:players)

    {:ok, game, assign(socket, :game, game)}
  end
end
