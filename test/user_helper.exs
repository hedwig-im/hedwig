defmodule UserHelper do

  import ExUnit.CaptureIO

  defmacro __using__(_) do
    quote do
      import UserHelper
    end
  end

  def setup_user(username) do
    {host, password} = {"localhost", "pass1234"}

    :ejabberd_admin.register(username, host, password)

    %{jid:      username <> "@" <> host,
      password: password,
      nickname: username,
      resource: "hedwig",
      config: %{port: 5223}}
  end

  def teardown_user(username) do
    :ejabberd_admin.unregister(username, "localhost")
  end

  def capture_log(fun) do
    capture_io(:user, fn ->
      fun.()
      Logger.flush()
    end)
  end
end
