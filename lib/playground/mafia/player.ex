defmodule Playground.Mafia.Player do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Playground.Mafia.{Game, PlayerRound}

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :name]}

  schema "players" do
    field(:name, :string)
    field(:role, RoleEnum)

    belongs_to(:game, Game, type: :binary_id)

    has_many(:player_rounds, PlayerRound)
    has_many(:player_statuses, through: [:player_rounds, :player_statuses])

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :game_id])
    |> validate_required([:name])
  end

  def incity(game_uuid) do
    Playground.Mafia.Player
    |> join(:left, [p], s in assoc(p, :player_statuses))
    |> where([p, s], p.game_id == ^game_uuid)
    |> where([p, s], is_nil(s.player_round_id) or s.type != ^:ostracized)
  end
end
