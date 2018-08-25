defmodule Playground.Mafia.Players.Chapter do
  defmacro __using__(_opts) do
    quote location: :keep do
      use GenServer

      def start_link({ game_uuid, player_uuid } = state) do
        GenServer.start_link(__MODULE__, state, name: via(game_uuid, player_uuid))
      end

      def start(game_uuid, player_uuid) do
        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [{game_uuid, player_uuid}]},
          restart: :transient
        }

        {:ok, pid} = Playground.Mafia.Narrator.start_child(game_uuid, spec)

        pid
      end

      def via(game_uuid, player_uuid) do
        {:via, Registry, { Playground.Mafia.Registry, { __MODULE__, game_uuid, player_uuid }}}
      end

      def init(state) do
        {:ok, state}
      end

      def handle_cast({:run, other_players}, { game_uuid, player_uuid } = state) do
        Registry.register(Playground.Mafia.Registry, {:current, game_uuid}, via(game_uuid, player_uuid))

        require Logger
        Logger.info __MODULE__

        case handle_run(game_uuid, player_uuid, other_players) do
          {:continue, state} ->
            {:noreply, state}
          _ ->
            {:stop, :shutdown, state}
        end
      end
    end
  end
end
