defmodule Playground.Repo.Migrations.CreatePlayerStatuses do
  use Ecto.Migration

  def change do
    create table(:player_statuses) do
      add(:player_round_id, references(:player_rounds, on_delete: :nothing))
      add(:type, :integer, null: false)
      add(:created_by_id, references(:players, on_delete: :nothing, type: :uuid))

      timestamps()
    end

    create(index(:player_statuses, [:player_round_id]))
  end
end
