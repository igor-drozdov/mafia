defmodule Playground.Mafia.Player do
  use Ecto.Schema

  import Ecto.Changeset

  alias Playground.Mafia.{Game, PlayerRound}

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :name]}

  schema "players" do
    field :name, :string
    field :role, RoleEnum

    belongs_to :game, Game, type: :binary_id

    has_many :player_rounds, PlayerRound
    has_many :rounds, through: [:player_rounds, :round]
    has_many :player_statuses, through: [:player_rounds, :player_statuses]

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :game_id])
    |> validate_required([:name])
  end
end
