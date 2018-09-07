defmodule Playground.Mafia.Chapters.DiscussionBegins do
  use Playground.Mafia.Chapter

  alias Playground.Mafia.Player
  alias Playground.Repo
  alias Playground.Mafia.Players.Chapters.PlayerSpeaks

  defp handle_run(%{game_uuid: game_uuid} = state) do
    players = Repo.all(Player.incity(game_uuid))

    PlayerSpeaks.run(game_uuid, players, Map.put(state, :players, players))

    {:stop, :shutdown, state}
  end
end
