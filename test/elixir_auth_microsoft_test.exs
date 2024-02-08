defmodule ElixirAuthMicrosoftTest do
  use ExUnit.Case, async: true
  doctest ElixirAuthMicrosoft

  # Tests the generated OAuth URL for localhost scenarios and passing state.
  test "generate_oauth_url_authorize(conn) for dev/localhost with state" do
    conn = %{
      host: "localhost",
      port: 4000
    }

    state = "random_state"
    id = System.get_env("MICROSOFT_CLIENT_ID")
    id_from_config = Application.get_env(:elixir_auth_microsoft, :client_id)

    assert id == id_from_config

    expected_redirect_uri = URI.encode_www_form("http://localhost:4000/auth/microsoft/callback")
    expected_scope = URI.encode_www_form("https://graph.microsoft.com/User.Read")

    expected =
      "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?&client_id=#{id}&response_type=code&redirect_uri=#{expected_redirect_uri}&scope=#{expected_scope}&response_mode=query&state=#{state}"

    assert ElixirAuthMicrosoft.generate_oauth_url_authorize(conn, state) == expected
  end

  # Tests the generated OAuth URL for when the package is used in production with a custom host.
  test "generate_oauth_url_authorize(conn) for production" do
    conn = %{
      host: "dwyl.com"
    }

    id = System.get_env("MICROSOFT_CLIENT_ID")
    id_from_config = Application.get_env(:elixir_auth_microsoft, :client_id)

    assert id == id_from_config

    expected_redirect_uri = URI.encode_www_form("https://dwyl.com/auth/microsoft/callback")
    expected_scope = URI.encode_www_form("https://graph.microsoft.com/User.Read")

    expected =
      "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?&client_id=#{id}&response_type=code&redirect_uri=#{expected_redirect_uri}&scope=#{expected_scope}&response_mode=query"

    assert ElixirAuthMicrosoft.generate_oauth_url_authorize(conn) == expected
  end

    # Tests the generated OAuth URL of logout
    test "generate_oauth_url_logout() for dev/localhost " do
      conn = %{
        host: "localhost",
        port: 4000
      }

      logout_url = System.get_env("MICROSOFT_POST_LOGOUT_REDIRECT_URI")
      logout_url_from_config = Application.get_env(:elixir_auth_microsoft, :post_logout_redirect_uri)

      assert logout_url == logout_url_from_config

      expected_redirect_uri = URI.encode_www_form("http://localhost:4000/auth/microsoft/logout")

      expected =
        "https://login.microsoftonline.com/common/oauth2/v2.0/logout?&post_logout_redirect_uri=#{expected_redirect_uri}"

      assert ElixirAuthMicrosoft.generate_oauth_url_logout() == expected
    end

  # Tests fetching the token by passing a certain token.
  test "get_token" do
    conn = %{
      host: "localhost",
      port: 4000
    }

    {:ok, res} = ElixirAuthMicrosoft.get_token("code123", conn)
    assert res == %{access_token: "token1"}
  end

  # Tests fetching the user profile by passing a specific token. Tests a positive case.
  test "get_user_profile(token)" do
    res = %{
      businessPhones: [],
      displayName: "Test Name",
      givenName: "Test",
      id: "192jnsd9010apd",
      jobTitle: nil,
      mail: nil,
      mobilePhone: '+351928837834',
      officeLocation: nil,
      preferredLanguage: nil,
      surname: "Name",
      userPrincipalName: "testemail@hotmail.com"
    }

    assert ElixirAuthMicrosoft.get_user_profile("token123") == {:ok, res}
  end

  # Tests fetching the user profile but with an invalid token. Tests a negative case.
  test "get_user_profile(token) with invalid token" do
    assert ElixirAuthMicrosoft.get_user_profile("invalid_token") == {:error, :bad_request}
  end


  ## TODO add env variables going as nil to test how the program behaves with no setup
end
