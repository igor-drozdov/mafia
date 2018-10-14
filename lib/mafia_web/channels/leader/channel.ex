defmodule MafiaWeb.Leader.Channel do
  use MafiaWeb, :channel

  alias Mafia.{Games, Repo}

  def join("leader:" <> id, _payload, socket) do
    game =
      Games.get_game!(id)
      |> Repo.preload(:players)

    new_state = init(game, game.state)

    {:ok, new_state, assign(socket, :game, game)}
  end

  def init(game, :finished) do
    %{state: game.winner.state}
  end

  def init(game, _) do
    game
  end
end
