defmodule Playground.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    execute("create TYPE game_state as enum ('init', 'current', 'finished')")

    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :state, :game_state

      timestamps()
    end

  end
end
