defmodule Playground.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def up do
    execute("create TYPE game_state as enum ('init', 'current', 'finished')")

    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :state, :game_state, default: "init"
      add :total, :integer

      timestamps()
    end
  end

  def down do
    drop table(:games)

    execute("drop TYPE game_state")
  end
end
