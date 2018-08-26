defmodule Playground.Mafia.Round do
  use Ecto.Schema
  import Ecto.Changeset

  alias Playground.Mafia.{Game, Player}

  schema "rounds" do
    belongs_to :game, Game, type: :binary_id
    many_to_many :players, Player, join_through: "player_rounds"

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:game_id])
    |> validate_required([:game_id])
  end
end
