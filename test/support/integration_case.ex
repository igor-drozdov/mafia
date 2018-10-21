defmodule MafiaWeb.IntegrationCase do
  use ExUnit.CaseTemplate
  use Hound.Helpers

  using do
    quote do
      use Hound.Helpers

      import Ecto, only: [build_assoc: 2]
      import Ecto.Query
      import Mafia.Factory
      import MafiaWeb.IntegrationCase

      alias Mafia.Repo

      @endpoint MafiaWeb.Endpoint

      hound_session()
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Mafia.Repo, ownership_timeout: 300000)
    Ecto.Adapters.SQL.Sandbox.mode(Mafia.Repo, {:shared, self()})

    :ok
  end
end
