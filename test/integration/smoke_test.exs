defmodule MafiaWeb.Integration.SmokeTest do
  use MafiaWeb.IntegrationCase

  @short_period Application.get_env(:mafia, :period) |> Keyword.fetch!(:short)
  @medium_period Application.get_env(:mafia, :period) |> Keyword.fetch!(:medium)
  @long_period Application.get_env(:mafia, :period) |> Keyword.fetch!(:long)
  @transport_delay 35
  @number_of_players 5

  def create_game do
    element = find_element(:name, "game[total]")
    fill_field(element, @number_of_players)
    submit_element(element)

    "http://localhost:4001/games/" <> game_uuid = current_url()

    game_uuid
  end

  def connect_players(players) do
    players
    |> Enum.with_index()
    |> Enum.each(&connect_player(&1, current_url()))

    players
  end

  def connect_player({player_name, index}, url) do
    change_session_to(player_name, user_agent: :safari_iphone)
    navigate_to(url)

    assert current_url() == url <> "/players/new"

    element = find_element(:name, "player[name]")
    fill_field(element, player_name)
    submit_element(element)

    change_to_default_session()

    leader_divs =
      find_element(:id, "players")
      |> find_all_within_element(:tag, "div")

    player_message =
      leader_divs
      |> Enum.at(2)
      |> find_all_within_element(:tag, "div")
      |> Enum.at(index)
      |> inner_text()

    :timer.sleep(@transport_delay)

    assert player_message == "#{player_name} has joined the game"
  end

  def player_speaks(player_name) do
    :timer.sleep(@transport_delay)

    element = find_element(:id, "player-can-speak")

    assert inner_text(element) == "\n#{player_name}, speak!"

    change_session_to(player_name, user_agent: :safari_iphone)

    find_element(:tag, "button") |> click

    :timer.sleep(@transport_delay)

    change_to_default_session()

    element =
      find_element(:id, "player-speaks")
      |> find_all_within_element(:tag, "div")
      |> Enum.at(2)

    assert inner_text(element) == "#{player_name} speaks!"

    :timer.sleep(@long_period)
  end

  def get_player(game_uuid, role) do
    Mafia.Players.Player.incity(game_uuid)
    |> where([p], p.role == ^role)
    |> Mafia.Repo.all()
    |> Enum.random()
  end

  def choose_player(player_name, innocent_name, sleep_time) when player_name == innocent_name do
    :timer.sleep(sleep_time)

    change_session_to(player_name, user_agent: :safari_iphone)

    :timer.sleep(@short_period)

    find_all_elements(:tag, "button")
    |> List.first()
    |> click()
  end

  def choose_player(player_name, innocent_name, sleep_time) do
    :timer.sleep(sleep_time)

    change_session_to(player_name, user_agent: :safari_iphone)

    :timer.sleep(@short_period)

    find_all_elements(:tag, "button")
    |> Enum.find(&(inner_text(&1) == String.upcase(innocent_name)))
    |> click()
  end

  def verify_player_ostrisized(player_name) do
    change_to_default_session()

    :timer.sleep(@transport_delay)

    message =
      find_element(:class, "ostrisized-player")
      |> inner_text()

    assert message == "\nThe following players is ostracized from city:\n#{player_name}"
  end

  def play_round(players, game_uuid, ostrisized_role) do
    :timer.sleep(@short_period)

    players
    |> Enum.each(&player_speaks(&1))

    innocent_player_name = get_player(game_uuid, ostrisized_role).name

    players
    |> Enum.each(&choose_player(&1, innocent_player_name, @transport_delay))

    players
    |> Enum.each(&choose_player(&1, innocent_player_name, @transport_delay))

    verify_player_ostrisized(innocent_player_name)

    :timer.sleep(@medium_period)

    players -- [innocent_player_name]
  end

  def mafia_wakes(players, game_uuid) do
    :timer.sleep(@short_period)

    mafia_player_name = get_player(game_uuid, :mafia).name
    innocent_player_name = get_player(game_uuid, :innocent).name

    choose_player(mafia_player_name, innocent_player_name, @transport_delay)

    :timer.sleep(@short_period)
    verify_player_ostrisized(innocent_player_name)

    players -- [innocent_player_name]
  end

  test "mafia wins", _meta do
    navigate_to("http://localhost:4001")

    game_uuid = create_game()

    players = Enum.map (1..@number_of_players), & "#{&1}_player"

    players
    |> connect_players()
    |> play_round(game_uuid, :innocent)
    |> mafia_wakes(game_uuid)
    |> play_round(game_uuid, :innocent)

    mafia_wins_img_src =
      find_element(:id, "mafia-wins")
      |> find_within_element(:tag, "img")
      |> attribute_value(:src)

    assert mafia_wins_img_src == "http://localhost:4001/images/mafia-wins.gif"

    :timer.sleep(@medium_period)
  end
end
