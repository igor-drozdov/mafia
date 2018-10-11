defmodule Mafia.Players.Round do
  use Ecto.Schema

  alias Mafia.{Repo, Players, Round}

  import Ecto.Query

  schema "player_rounds" do
    belongs_to(:player, Players.Player, type: :binary_id)
    belongs_to(:round, Round)
    has_many(:player_statuses, Players.Status)

    timestamps()
  end

  def create_status(round_id, target_player_uuid, type, created_by_id \\ nil) do
    Players.Round
    |> where(player_id: ^target_player_uuid, round_id: ^round_id)
    |> Repo.one()
    |> Ecto.build_assoc(:player_statuses, %{type: type, created_by_id: created_by_id})
    |> Repo.insert!()
  end
end
