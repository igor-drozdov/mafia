defmodule Playground.Mafia.Winner do
  use Ecto.Schema
  import Ecto.Changeset

  alias Playground.Mafia.Game

  schema "winners" do
    field(:state, WinnerStateEnum)
    belongs_to(:game, Game, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(winner, attrs) do
    winner
    |> cast(attrs, [:state, :game_id])
    |> validate_required([:state])
  end
end