defmodule PlaygroundWeb.GameView do
  use PlaygroundWeb, :view

  defp mobile?(user_agent) do
    Regex.match?(~r/Mobile|webOS/, user_agent)
  end
end
