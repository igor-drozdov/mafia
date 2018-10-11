defmodule Mafia.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Mafia.Repo

  alias Mafia.Games.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)
  def get_game(id), do: Repo.get(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end

  alias Playground.Mafia.Round

  @doc """
  Returns the list of rounds.

  ## Examples

      iex> list_rounds()
      [%Round{}, ...]

  """
  def list_rounds do
    Repo.all(Round)
  end

  @doc """
  Gets a single round.

  Raises `Ecto.NoResultsError` if the Round does not exist.

  ## Examples

      iex> get_round!(123)
      %Round{}

      iex> get_round!(456)
      ** (Ecto.NoResultsError)

  """
  def get_round!(id), do: Repo.get!(Round, id)

  @doc """
  Creates a round.

  ## Examples

      iex> create_round(%{field: value})
      {:ok, %Round{}}

      iex> create_round(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_round(attrs \\ %{}) do
    %Round{}
    |> Round.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a round.

  ## Examples

      iex> update_round(round, %{field: new_value})
      {:ok, %Round{}}

      iex> update_round(round, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_round(%Round{} = round, attrs) do
    round
    |> Round.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Round.

  ## Examples

      iex> delete_round(round)
      {:ok, %Round{}}

      iex> delete_round(round)
      {:error, %Ecto.Changeset{}}

  """
  def delete_round(%Round{} = round) do
    Repo.delete(round)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking round changes.

  ## Examples

      iex> change_round(round)
      %Ecto.Changeset{source: %Round{}}

  """
  def change_round(%Round{} = round) do
    Round.changeset(round, %{})
  end

  alias Playground.Mafia.Winner

  @doc """
  Returns the list of winners.

  ## Examples

      iex> list_winners()
      [%Winner{}, ...]

  """
  def list_winners do
    Repo.all(Winner)
  end

  @doc """
  Gets a single winner.

  Raises `Ecto.NoResultsError` if the Winner does not exist.

  ## Examples

      iex> get_winner!(123)
      %Winner{}

      iex> get_winner!(456)
      ** (Ecto.NoResultsError)

  """
  def get_winner!(id), do: Repo.get!(Winner, id)

  @doc """
  Creates a winner.

  ## Examples

      iex> create_winner(%{field: value})
      {:ok, %Winner{}}

      iex> create_winner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_winner(attrs \\ %{}) do
    %Winner{}
    |> Winner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a winner.

  ## Examples

      iex> update_winner(winner, %{field: new_value})
      {:ok, %Winner{}}

      iex> update_winner(winner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_winner(%Winner{} = winner, attrs) do
    winner
    |> Winner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Winner.

  ## Examples

      iex> delete_winner(winner)
      {:ok, %Winner{}}

      iex> delete_winner(winner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_winner(%Winner{} = winner) do
    Repo.delete(winner)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking winner changes.

  ## Examples

      iex> change_winner(winner)
      %Ecto.Changeset{source: %Winner{}}

  """
  def change_winner(%Winner{} = winner) do
    Winner.changeset(winner, %{})
  end
end
