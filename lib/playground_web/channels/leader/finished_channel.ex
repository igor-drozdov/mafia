defmodule PlaygroundWeb.Leader.FinishedChannel do
  use PlaygroundWeb, :channel

  alias Mafia.{Games, Repo}

  def join("leader:finished:" <> id, _payload, socket) do
    game =
      Games.get_game!(id)
      |> Repo.preload(:winner)

    {:ok, %{state: game.winner.state}, assign(socket, :game, game)}
  end
end
