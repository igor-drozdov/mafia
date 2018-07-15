defmodule Playground.Mafia.Game do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @derive {Poison.Encoder, only: [:id, :state, :players]}

  schema "games" do
    field :state, :string

    has_many :players, Playground.Mafia.Player

    timestamps()
  end

  @doc false
  def changeset(game, _attrs) do
    game
  end
end
