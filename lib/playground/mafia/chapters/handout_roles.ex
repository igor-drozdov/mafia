defmodule Playground.Mafia.Chapters.HandoutRoles do
  use Playground.Mafia.Chapter

  import Ecto.Query

  alias PlaygroundWeb.Endpoint
  alias Playground.Mafia.{Player, Chapters.RoundBegins}
  alias Playground.{Mafia, Repo}

  defp handle_run(game_uuid) do
    game = Mafia.get_game!(game_uuid) |> Repo.preload(:players)
    player_uuids = Enum.map(game.players, & &1.id)

    handout_roles(game.id, player_uuids)

    Process.send_after(self(), :transition, 3000)

    {:continue, game_uuid}
  end

  def handout_roles(game_uuid, player_uuids) do
    number_of_mafias = div(length(player_uuids), 3)
    {mafias, innocents} = player_uuids |> Enum.shuffle |> Enum.split(number_of_mafias)

    Enum.each([mafia: mafias, innocent: innocents], fn {role, players} ->
			from(p in Player, where: p.id in ^players)
			|> Repo.update_all(set: [role: role])

      Enum.each players, &
        Endpoint.broadcast(
          "rooms:followers:init:#{game_uuid}:#{&1}", "role_received", %{role: role})
    end)
  end

  def handle_info(:transition, game_uuid) do
    RoundBegins.run(game_uuid)

    {:noreply, game_uuid}
  end
end
