defmodule MafiaWeb.Leader.InitChannel do
  use MafiaWeb, :channel

  alias Mafia.{Games, Repo}

  def join("leader:init:" <> id, _payload, socket) do
    game =
      Games.get_game!(id)
      |> Repo.preload(:players)

    {:ok, game, assign(socket, :game, game)}
  end
end
