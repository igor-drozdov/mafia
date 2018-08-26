defmodule Playground.Mafia.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Playground.Mafia.{Player, Round}

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :state, :total, :players]}

  schema "games" do
    field :state, GameStateEnum
    field :total, :integer

    has_many :players, Player
    has_many :rounds, Round

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:total, :state])
  end
end
