defmodule PlaygroundWeb.Leader.CurrentChannel do
  use PlaygroundWeb, :channel

  alias Playground.{Mafia, Repo}

  def join("leader:current:" <> id, _payload, socket) do
    game =
      Mafia.get_game!(id)
      |> Repo.preload(:players)

    {:ok, game, assign(socket, :game, game)}
  end
end
