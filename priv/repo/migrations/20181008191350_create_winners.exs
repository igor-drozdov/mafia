defmodule Mafia.Repo.Migrations.CreateWinners do
  use Ecto.Migration

  def change do
    create table(:winners) do
      add :state, :integer
      add :game_id, references(:games, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:winners, [:game_id])
  end
end
