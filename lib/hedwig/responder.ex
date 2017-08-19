defmodule Hedwig.Responder do
  @moduledoc ~S"""
  Base module for building responders.

  A responder is a module which setups up handlers for hearing and responding
  to incoming messages.

  ## Hearing & Responding

  Hedwig can hear messages said in a room or respond to messages directly
  addressed to it. Both methods take a regular expression, the message and a block
  to execute when there is a match. For example:

      hear ~r/(hi|hello)/i, msg do
        # your code here
      end

      respond ~r/help$/i, msg do
        # your code here
      end

  ## Using captures

  Responders support regular expression captures. It supports both normal
  captures and named captures. When a message matches, captures are handled
  automatically and added to the message's `:matches` key.

  Accessing the captures depends on the type of capture used in the responder's
  regex. If named captures are used, captures will be available by the name,
  otherwise it will be available by an index, starting with 0.


  ### Example:

      # with indexed captures
      hear ~r/i like (\w+), msg do
        emote msg, "likes #{msg.matches[1]} too!"
      end

      # with named captures
      hear ~r/i like (?<subject>\w+), msg do
        emote msg, "likes #{msg.matches["subject"]} too!"
      end
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      import unquote(__MODULE__)
      import Kernel, except: [send: 2]

      Module.register_attribute __MODULE__, :hear, accumulate: true
      Module.register_attribute __MODULE__, :respond, accumulate: true
      Module.register_attribute __MODULE__, :usage, accumulate: true

      @before_compile unquote(__MODULE__)
    end
  end

  def start_link(module, {aka, name, opts, robot}) do
    GenServer.start_link(module, {aka, name, opts, robot})
  end

  @doc """
  Sends a message via the underlying adapter.

  ## Example

      send msg, "Hello there!"
  """
  def send(%Hedwig.Message{robot: robot} = msg, text) do
    Hedwig.Robot.send(robot, %{msg | text: text})
  end

  @doc """
  Send a reply message via the underlying adapter.

  ## Example

      reply msg, "Hello there!"
  """
  def reply(%Hedwig.Message{robot: robot} = msg, text) do
    Hedwig.Robot.reply(robot, %{msg | text: text})
  end

  @doc """
  Send an emote message via the underlying adapter.

  ## Example

      emote msg, "goes and hides"
  """
  def emote(%Hedwig.Message{robot: robot} = msg, text) do
    Hedwig.Robot.emote(robot, %{msg | text: text})
  end

  @doc """
  Returns a random item from a list or range.

  ## Example

      send msg, random(["apples", "bananas", "carrots"])
  """
  def random(list) do
    :rand.seed(:exsplus, :os.timestamp)
    Enum.random(list)
  end

  @doc false
  def dispatch(msg, responders) do
    Enum.map(responders, fn {_, pid, _, _} ->
      GenServer.cast(pid, {:dispatch, msg})
    end)
  end

  @doc """
  Matches messages based on the regular expression.

  ## Example

      hear ~r/hello/, msg do
        # code to handle the message
      end
  """
  defmacro hear(regex, msg, state \\ Macro.escape(%{}), do: block) do
    name = unique_name(:hear)
    quote do
      @hear {unquote(regex), unquote(name)}
      @doc false
      def unquote(name)(unquote(msg), unquote(state)) do
        unquote(block)
      end
    end
  end

  @doc """
  Setups up an responder that will match when a message is prefixed with the bot's name.

  ## Example

      # Give our bot's name is "alfred", this responder
      # would match for a message with the following text:
      # "alfred hello"
      respond ~r/hello/, msg do
        # code to handle the message
      end
  """
  defmacro respond(regex, msg, state \\ Macro.escape(%{}), do: block) do
    name = unique_name(:respond)
    quote do
      @respond {unquote(regex), unquote(name)}
      @doc false
      def unquote(name)(unquote(msg), unquote(state)) do
        unquote(block)
      end
    end
  end

  defp unique_name(type) do
    String.to_atom("#{type}_#{System.unique_integer([:positive, :monotonic])}")
  end

  @doc false
  def respond_pattern(pattern, name, aka) do
    pattern
    |> Regex.source
    |> rewrite_source(name, aka)
    |> Regex.compile!(Regex.opts(pattern))
  end

  defp rewrite_source(source, name, nil) do
    "^\\s*[@]?#{name}[:,]?\\s*(?:#{source})"
  end
  defp rewrite_source(source, name, aka) do
    [a, b] = if String.length(name) > String.length(aka), do: [name, aka], else: [aka, name]
    "^\\s*[@]?(?:#{a}[:,]?|#{b}[:,]?)\\s*(?:#{source})"
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      @doc false
      def usage(name) do
        import String
        Enum.map(@usage, &(&1 |> trim |> replace("hedwig", name)))
      end

      def init({aka, name, opts, robot}) do
        :ok = GenServer.cast(self(), :compile_responders)

        {:ok, %{
          aka: aka,
          name: name,
          opts: opts,
          responders: [],
          robot: robot}}
      end

      def handle_cast(:compile_responders, %{aka: aka, name: name} = state) do
        {:noreply, %{state | responders: compile_responders(name, aka)}}
      end

      def handle_cast({:dispatch, msg}, state) do
        {:noreply, dispatch_responders(msg, state)}
      end

      defp dispatch_responders(msg, %{responders: responders} = state) do
        Enum.reduce responders, state, fn responder, new_state ->
          case dispatch_responder(responder, msg, new_state) do
            :ok ->
              new_state
            {:ok, new_state} ->
              new_state
          end
        end
      end

      defp dispatch_responder({regex, fun}, %{text: text} = msg, state) do
        if Regex.match?(regex, text) do
          msg = %{msg | matches: find_matches(regex, text)}
          apply(__MODULE__, fun, [msg, state])
        else
          :ok
        end
      end

      defp find_matches(regex, text) do
        case Regex.names(regex) do
          []  ->
            matches = Regex.run(regex, text)
            Enum.reduce(Enum.with_index(matches), %{}, fn {match, index}, acc ->
              Map.put(acc, index, match)
            end)
          _ ->
            Regex.named_captures(regex, text)
        end
      end

      defp compile_responders(name, aka) do
        responders = for {regex, fun} <- @respond do
          regex = Hedwig.Responder.respond_pattern(regex, name, aka)
          {regex, fun}
        end

        List.flatten([@hear, responders])
      end
    end
  end
end
