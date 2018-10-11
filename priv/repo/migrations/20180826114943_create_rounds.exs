defmodule Mafia.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :game_id, references(:games, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:rounds, [:game_id])
  end
end
