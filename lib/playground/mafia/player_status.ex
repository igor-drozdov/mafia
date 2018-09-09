defmodule Playground.Mafia.PlayerStatus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_statuses" do
    field(:type, PlayerStateEnum)

    belongs_to(:player_round, Playground.Mafia.PlayerRound)
    belongs_to(:created_by, Playground.Mafia.Player, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(player_status, attrs) do
    player_status
    |> cast(attrs, [])
    |> validate_required([])
  end
end
