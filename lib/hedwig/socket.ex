defmodule Hedwig.Socket do
  @moduledoc """
  XMPP Socket connection
  """

  @doc """
  """
  @spec connect(server :: binary, port :: integer | 5222) :: port | {:error, :nxdomain}
  def connect(server, port \\ 5222) do
    Socket.TCP.connect server, port, mode: :active
  end

  def send!(socket, data) do
    Socket.Stream.send! socket, data |> :exml.to_binary
  end
end
