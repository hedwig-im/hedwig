defmodule Hedwig.Responder do
  @moduledoc """
  Base module for building responders.

  A responder is a module which setups up handlers for hearing and responding
  to incoming messages.

  ## Hearing & Responding

  Hedwig can hear messages said in a room or respond to messages directly
  addressed to it. Both methods take a regular expression, the message and a block
  to execute when there is a match. For example:

      hear ~/(hi|hello)/i, msg do
        # your code here
      end

      respond ~/help/i, msg do
        # your code here
      end
  """

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)
      import Kernel, except: [send: 2]

      Module.register_attribute __MODULE__, :hear, accumulate: true
      Module.register_attribute __MODULE__, :respond, accumulate: true
      Module.register_attribute __MODULE__, :usage, accumulate: true

      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Sends a message via the underlying adapter.
  """
  def send(%Hedwig.Message{adapter: {mod, pid}} = msg, text) do
    mod.send(pid, %{msg | text: text})
  end

  @doc """
  Send a reply message via the underlying adapter.
  """
  def reply(%Hedwig.Message{adapter: {mod, pid}} = msg, text) do
    mod.reply(pid, %{msg | text: text})
  end

  @doc """
  Send an emote message via the underlying adapter.
  """
  def emote(%Hedwig.Message{adapter: {mod, pid}} = msg, text) do
    mod.emote(pid, %{msg | text: text})
  end

  @doc """
  Returns a random item from a list.
  """
  def random(list) when is_list(list) do
    :random.seed(:os.timestamp)
    Enum.random(list)
  end

  @doc false
  def run(msg, responders) do
    Enum.map(responders, &run_aysnc(msg, &1))
  end

  defp run_aysnc(%{text: text} = msg, {regex, mod, fun, opts}) do
    Task.async(fn ->
      if Regex.match?(regex, text) do
        msg = %{msg | matches: matches(regex, text)}
        apply(mod, fun, [msg, opts])
      else
        nil
      end
    end)
  end

  defp matches(regex, text) do
    case Regex.names(regex) do
      []  ->
        matches = Regex.run(regex, text)
        Enum.reduce(Enum.with_index(matches), %{}, fn {match, index}, acc ->
          Map.put(acc, index, match)
        end)
      [_] ->
        Regex.named_captures(regex, text)
    end
  end

  defmacro hear(regex, msg, opts \\ Macro.escape(%{}), do: block) do
    source = source(regex)
    quote do
      @hear {unquote(regex), unquote(source)}
      def unquote(source)(unquote(msg), unquote(opts)) do
        unquote(block)
      end
    end
  end

  defmacro respond(regex, msg, opts \\ Macro.escape(%{}), do: block) do
    source = source(regex)
    quote do
      @respond {unquote(regex), unquote(source)}
      def unquote(source)(unquote(msg), unquote(opts)) do
        unquote(block)
      end
    end
  end

  defp source({:sigil_r, _, [{:<<>>, _, [source]}, _]}),
    do: String.to_atom("__" <> source <> "__")

  @doc false
  def respond_pattern(pattern, robot) do
    pattern
    |> Regex.source
    |> rewrite_source(robot.name, robot.aka)
    |> Regex.compile!(Regex.opts(pattern))
  end

  defp rewrite_source(source, name, nil) do
    "^\\s*[@]?#{name}[:,]?\\s*(?:#{source})"
  end
  defp rewrite_source(source, name, aka) do
    [a, b] = if String.length(name) > String.length(aka), do: [name, aka], else: [aka, name]
    "^\\s*[@]?(?:#{a}[:,]?|#{b}[:,]?)\\s*(?:#{source})"
  end

  defmacro __before_compile__(env) do
    quote do
      def usage(name) do
        @usage
        |> Enum.map(&String.strip/1)
        |> Enum.map(&(String.replace(&1, "hedwig", name)))
        |> Enum.reverse
      end

      def __hearers__ do
        @hear
      end

      def __responders__ do
        @respond
      end

      def install(robot, opts) do
        hearers =
          __hearers__
          |> Enum.map(&install_hearer(&1, robot, opts))
          |> Enum.map(&Task.await/1)

        responders =
          __responders__
          |> Enum.map(&install_responder(&1, robot, opts))
          |> Enum.map(&Task.await/1)

        List.flatten([hearers, responders])
      end

      defp install_hearer({regex, fun}, _robot, opts) do
        Task.async(fn ->
          {regex, __MODULE__, fun, Enum.into(opts, %{})}
        end)
      end

      defp install_responder({regex, fun}, robot, opts) do
        Task.async(fn ->
          regex = Hedwig.Responder.respond_pattern(regex, robot)
          {regex, __MODULE__, fun, Enum.into(opts, %{})}
        end)
      end
    end
  end
end
