defmodule MafiaWeb.PageControllerTest do
  use MafiaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Create Game"
  end
end
