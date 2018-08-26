defmodule Playground.Mafia.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :name]}

  schema "players" do
    field :name, :string
    field :role, RoleEnum

    belongs_to :game, Playground.Mafia.Game, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :game_id])
    |> validate_required([:name])
  end
end
