defmodule Playground.Mafia.Chapters.DiscussionBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Player
  alias Playground.Repo
  alias Playground.Mafia.Players.Chapters.PlayerSpeaks

  import Ecto.Query, only: [from: 2]

  defp handle_run(game_uuid) do
    player_uuids =
      Repo.all(
        from p in Player,
        where: [game_id: ^game_uuid, state: "incity"],
        select: map(p, [:id])
      ) |> Enum.map(& &1.id)

    PlayerSpeaks.run(game_uuid, player_uuids)
  end
end
