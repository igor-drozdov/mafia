defmodule Playground.Mafia.Chapters.DiscussionBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Player
  alias Playground.Repo
  alias Playground.Mafia.Players.Chapters.PlayerSpeaks

  defp handle_run(%{game_uuid: game_uuid}) do
    player_uuids =
      Player.incity(game_uuid)
      |> Repo.all()
      |> Enum.map(& &1.id)

    PlayerSpeaks.run(game_uuid, player_uuids)
  end
end
