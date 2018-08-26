defmodule Playground.Mafia.Round do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rounds" do
    belongs_to :game, Playground.Mafia.Game, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:game_id])
    |> validate_required([:game_id])
  end
end
