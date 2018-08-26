defmodule Playground.Mafia.Player do
  use Ecto.Schema

  import Ecto.Changeset

  alias Playground.Mafia.{Game, Round}

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :name]}

  schema "players" do
    field :name, :string
    field :role, RoleEnum

    belongs_to :game, Game, type: :binary_id
    many_to_many :rounds, Round, join_through: "player_rounds"

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :game_id])
    |> validate_required([:name])
  end
end
