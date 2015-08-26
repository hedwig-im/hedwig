defmodule UserHelper do

  import ExUnit.CaptureIO

  defmacro __using__(_) do
    quote do
      import UserHelper
    end
  end

  def build_user(username, host \\ "localhost", password \\ "pass1234") do
    %{jid:      username <> "@" <> host,
      password: password,
      nickname: username,
      resource: "hedwig",
      config: %{port: 5223}}
  end

  def setup_user(username, host \\ "localhost", password \\ "pass1234") do
    user = build_user(username, host, password)
    :ejabberd_admin.register(username, host, password)
    user
  end

  def teardown_user(username, host \\ "localhost") do
    :ejabberd_admin.unregister(username, host)
  end

  def capture_log(fun) do
    capture_io(:user, fn ->
      fun.()
      Logger.flush()
    end)
  end
end
