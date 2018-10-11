defmodule Mafia.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :state, :integer, default: 0
      add :total, :integer

      timestamps()
    end
  end
end
