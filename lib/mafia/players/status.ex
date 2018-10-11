defmodule Mafia.Players.Status do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mafia.Players.{Round, Player}

  schema "player_statuses" do
    field(:type, PlayerStateEnum)

    belongs_to(:player_round, Round)
    belongs_to(:created_by, Player, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(player_status, attrs) do
    player_status
    |> cast(attrs, [])
    |> validate_required([])
  end
end
