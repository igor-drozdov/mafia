defmodule PlaygroundWeb.Leader.FinishedChannel do
  use PlaygroundWeb, :channel

  alias Playground.{Mafia, Repo}

  def join("leader:finished:" <> id, _payload, socket) do
    game =
      Mafia.get_game!(id)
      |> Repo.preload(:winner)

    {:ok, %{state: game.winner.state}, assign(socket, :game, game)}
  end
end
