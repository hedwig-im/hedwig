defmodule Hedwig.Handler do
  use Hedwig.XML

  alias Hedwig.JID
  alias Hedwig.Client

  defmacro __using__(_opts) do
    quote do
      use GenEvent
      use Hedwig.XML

      alias Hedwig.JID
      alias Hedwig.Client
      alias Hedwig.Stanzas.IQ
      alias Hedwig.Stanzas.Message
      alias Hedwig.Stanzas.Presence

      require Logger
      import unquote __MODULE__

      def usage, do: @usage
    end
  end

  @doc """
  Gets opts for the given handler from the client config.
  """
  def get_opts(client, handler) when is_atom(handler) do
    {_handler, opts} = client.handlers |> List.keyfind(handler, 0, %{})
    merge_client_opts(client, opts)
  end

  @doc """
  Merge client options with handler options.
  """
  def merge_client_opts(client, opts) when is_map(opts) do
    %{client: Map.take(client, [:jid, :resource, :nickname])}
    |> Map.merge(opts)
  end

  @doc """
  Send a reply via the client pid.
  """
  def reply(msg, body) do
    client = msg.client
    msg = Stanza.message(JID.bare(msg.from), msg.type, body)
    Client.reply(client, msg)
  end

  def groupchat(msg, body) do
    client = msg.client
    msg = Stanza.message(JID.bare(msg.to), "groupchat", body)
    Client.reply(client, msg)
  end

  def hear(regex, msg) do
    Regex.match?(regex, msg.body)
  end

  def respond(regex, msg) do
    Regex.named_captures(regex, msg.body)
  end
end
