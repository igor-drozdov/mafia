defmodule Playground.Mafia.PlayerRound do
  use Ecto.Schema

  alias Playground.Mafia.{Player, Round, PlayerStatus}

  schema "player_rounds" do
    belongs_to :player, Player, type: :binary_id
    belongs_to :round, Round
    has_many :player_statuses, PlayerStatus

    timestamps()
  end
end
