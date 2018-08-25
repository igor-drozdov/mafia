defmodule Playground.Mafia.Chapters.SelectionBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Player
  alias Playground.Repo
  alias Playground.Mafia.Players.Chapters.PlayerChooses

  import Ecto.Query, only: [from: 2]

  defp handle_run(game_uuid) do
    player_uuids =
      Repo.all(
        from p in Player,
        where: [game_id: ^game_uuid, state: "current"],
        select: map(p, [:id])
      ) |> Enum.map(& &1.id)

    PlayerChooses.run(game_uuid, player_uuids)
  end
end
