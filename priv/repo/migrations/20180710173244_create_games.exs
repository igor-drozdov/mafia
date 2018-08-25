defmodule Playground.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def up do
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :state, :integer, default: 0
      add :total, :integer

      timestamps()
    end
  end

  def down do
    drop table(:games)

    execute("drop TYPE game_state")
  end
end
