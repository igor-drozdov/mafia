defmodule Playground.Repo.Migrations.CreatePlayerRounds do
  use Ecto.Migration

  def change do
    create table(:player_rounds) do
      add :player_id, references(:players, on_delete: :delete_all, type: :uuid)
      add :round_id, references(:rounds, on_delete: :nothing)

      timestamps()
    end

    create index(:player_rounds, [:player_id])
    create index(:player_rounds, [:round_id])
  end
end
