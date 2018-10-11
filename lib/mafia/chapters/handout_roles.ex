defmodule Mafia.Chapters.HandoutRoles do
  use Mafia.Chapter

  import Ecto.Query

  alias PlaygroundWeb.Endpoint
  alias Mafia.Chapters.StartGame
  alias Mafia.{Games, Players.Player}

  defp handle_run(%{game_uuid: game_uuid}) do
    handout_roles(game_uuid)
    notify_leader(game_uuid)
    start_game(game_uuid)
  end

  def handout_roles(game_uuid) do
    players =
      Games.get_game!(game_uuid)
      |> Repo.preload(:players)
      |> Map.fetch!(:players)

    number_of_mafias = div(length(players), 3)
    {mafias, innocents} = players |> Enum.shuffle() |> Enum.split(number_of_mafias)

    assign_role(game_uuid, mafias, :mafia, mafias)
    assign_role(game_uuid, innocents, :innocent)
  end

  defp assign_role(game_uuid, players, role, known_players \\ []) do
    player_uuids = Enum.map(players, & &1.id)

    from(p in Player, where: p.id in ^player_uuids)
    |> Repo.update_all(set: [role: role])

    Enum.each(
      players,
      &Endpoint.broadcast("followers:init:#{game_uuid}:#{&1.id}", "role_received", %{
        role: role,
        players: List.delete(known_players, &1)
      })
    )
  end

  def notify_leader(game_uuid) do
    Endpoint.broadcast("leader:init:#{game_uuid}", "roles_assigned", %{audio: "roles_assigned"})
  end

  def start_game(game_uuid) do
    StartGame.run(game_uuid)

    {:stop, :shutdown, game_uuid}
  end
end
