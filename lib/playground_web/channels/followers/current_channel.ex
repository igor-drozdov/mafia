defmodule PlaygroundWeb.Followers.CurrentChannel do
  use PlaygroundWeb, :channel

  alias PlaygroundWeb.Endpoint
  alias Playground.{Mafia, Repo}

  def join("followers:current:" <> ids, _payload, socket) do
    {:ok, socket}
  end
end
