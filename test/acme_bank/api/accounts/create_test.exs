defmodule AcmeBank.Api.Accounts.CreateTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Api.Router
  alias AcmeBank.AccountsMock
  alias AcmeBank.Accounts.Account

  @opts Router.init([])

  test "valid request" do
    account = %Account{
      name: "My Account",
      id: "abc-123",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    AccountsMock
    |> expect(:create_account, fn %{"name" => "My Account"} -> {:ok, account} end)

    conn = conn(:post, "/accounts", %{name: "My Account"})

    conn = Router.call(conn, @opts)

    assert conn.status == 200

    assert conn.resp_body ==
             Jason.encode!(Map.take(account, [:id, :name, :inserted_at, :updated_at]))
  end

  test "invalid request" do
    errors = %{
      name: [%{msg: "is required", rules: %{validation: :requierd}}]
    }

    AccountsMock
    |> expect(:create_account, fn %{} -> {:error, errors} end)

    conn = conn(:post, "/accounts")

    conn = Router.call(conn, @opts)

    assert conn.status == 400

    assert conn.resp_body ==
             Jason.encode!(%{errors: errors})
  end
end
