defmodule Mafia.Games.Round do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mafia.{Games.Game, Players}

  schema "rounds" do
    belongs_to(:game, Game, type: :binary_id)

    has_many(:player_rounds, Players.Round)
    has_many(:players, through: [:player_rounds, :player])
    has_many(:player_statuses, through: [:player_rounds, :player_statuses])

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:game_id])
    |> validate_required([:game_id])
  end
end
