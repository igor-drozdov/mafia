defmodule Playground.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def up do
    create table(:players, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :state, :integer, default: 0
      add :role, :integer
      add :game_id, references(:games, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:players, [:game_id])
  end

  def down do
    drop table(:players)

    execute("drop TYPE player_state")
  end
end
