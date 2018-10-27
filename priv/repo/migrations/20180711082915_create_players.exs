defmodule Mafia.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:role, :integer)
      add(:game_id, references(:games, on_delete: :delete_all, type: :uuid))

      timestamps()
    end

    create(index(:players, [:game_id]))
  end
end
