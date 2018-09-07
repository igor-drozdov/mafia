defmodule Playground.Mafia.PlayerRound do
  use Ecto.Schema

  alias Playground.Mafia.{Player, Round, PlayerStatus, PlayerRound}
  alias Playground.Repo

  import Ecto.Query

  schema "player_rounds" do
    belongs_to :player, Player, type: :binary_id
    belongs_to :round, Round
    has_many :player_statuses, PlayerStatus

    timestamps()
  end

  def create_status(round_id, player_uuid, type) do
    PlayerRound
    |> where(player_id: ^player_uuid, round_id: ^round_id)
    |> Repo.one()
    |> Ecto.build_assoc(:player_statuses, %{ type: type })
    |> Repo.insert()
  end
end
