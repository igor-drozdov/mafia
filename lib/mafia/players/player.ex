defmodule Mafia.Players.Player do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Mafia.Players.{Round, Player}
  alias Mafia.{Repo, Games.Game}

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :name]}

  schema "players" do
    field(:name, :string)
    field(:role, RoleEnum)

    belongs_to(:game, Game, type: :binary_id)

    has_many(:player_rounds, Round)
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
    ostricized_player_ids =
      Player
      |> join(:inner, [p], ps in assoc(p, :player_statuses), ps.type == ^:ostracized)
      |> select([p], p.id)
      |> order_by([p], p.inserted_at)
      |> Repo.all()

    Player |> where([p], p.game_id == ^game_uuid and p.id not in ^ostricized_player_ids)
  end

  def by_status(round_id, type) do
    Player
    |> join(:inner, [p], pr in assoc(p, :player_rounds), pr.round_id == ^round_id)
    |> join(:inner, [p, pr], ps in assoc(pr, :player_statuses), ps.type == ^type)
    |> distinct(true)
  end
end
