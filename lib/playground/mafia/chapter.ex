defmodule Playground.Mafia.Chapter do
  defmacro __using__(_opts) do
    quote location: :keep do
      use GenServer

      def start_link(game_uuid) do
        GenServer.start_link(__MODULE__, game_uuid, name: via(game_uuid))
      end

      def via(game_uuid) do
        {:via, Registry, { Playground.Mafia.Registry, { __MODULE__, game_uuid }}}
      end

      def init(state) do
        {:ok, state}
      end

      def run(game_uuid) do
        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [game_uuid]},
          restart: :transient
        }

        {:ok, pid} = Playground.Mafia.Narrator.start_child(game_uuid, spec)
        GenServer.cast(pid, :run)
      end

      def handle_cast(:run, game_uuid) do
        Registry.register(Playground.Mafia.Registry, {:current, game_uuid}, via(game_uuid))

        require Logger
        Logger.info __MODULE__

        case handle_run(game_uuid) do
          {:continue, game_uuid} ->
            {:noreply, game_uuid}
          _ ->
            {:stop, :shutdown, game_uuid}
        end
      end
    end
  end
end
