defmodule Playground.Mafia.PlayerRound do
  use Ecto.Schema

  schema "player_rounds" do
    belongs_to :player, Playground.Mafia.Player, type: :binary_id
    belongs_to :round, Playground.Mafia.Round

    timestamps()
  end
end
