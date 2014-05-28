defmodule Hedwig.Socket do
  @moduledoc """
  XMPP Socket connection
  """

  @doc """
  Open a socket connection to the XMPP server.
  """
  @spec connect(server :: binary, port :: integer | 5222) :: port | {:error, :nxdomain}
  def connect(server, port \\ 5222) do
    :gen_tcp.connect(List.from_char_data!(server), port, [:binary, {:active, true}, {:keepalive, true}])
  end

  @spec send(socket :: port, data :: binary) :: :ok | {:error, binary}
  def send(socket, data) do
    :gen_tcp.send socket, data |> :exml.to_binary
  end
end
