defmodule Hedwig.Robot do
  @moduledoc """
  A behaviour module for implementing robot processes.

  Robots receive messages from a chat source (XMPP, Slack, Console, etc), and
  dispatch them to matching responders. See the documentation for
  `Hedwig.Responder` for details on responders.

  When used, the robot expects the `:otp_app` as option. The `:otp_app` should
  point to an OTP application that has the robot configuration. For example,
  the robot:

      defmodule MyApp.Robot do
        use Hedwig.Robot, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, MyApp.Robot,
        adapter: Hedwig.Adapters.Console,
        name: "alfred"

  Most of the configuration that goes into the `config` is specific to the
  adapter. Be sure to check the documentation for the adapter in use for all
  of the available options.

  ## Robot configuration

  * `adapter` - the adapter module name.
  * `name` - the name the robot will respond to.
  * `aka` - an alias the robot will respond to.
  * `responders` - a list of responders specified in the following format:
    `{module, kwlist}`.
  """

  @behaviour :gen_server

  @type adapter :: pid
  @type aka :: binary
  @type backoff :: integer
  @type mod :: module
  @type mod_state :: any
  @type name :: binary
  @type opts :: Keyword.t
  @type raise :: any
  @type responder_sup :: pid
  @type responders :: [{module, Keyword.t}]
  @type robot :: pid

  @type t :: %__MODULE__{
    adapter: adapter,
    aka: aka,
    backoff: backoff,
    mod: mod,
    mod_state: mod_state,
    name: name,
    opts: opts,
    raise: raise,
    responder_sup: responder_sup,
    responders: responders
  }

  defstruct adapter: nil,
            aka: nil,
            backoff: 0,
            mod: nil,
            mod_state: nil,
            name: "",
            opts: [],
            raise: nil,
            responder_sup: nil,
            responders: []

  @callback handle_connect(any, any) ::
    {:ok, any} | {:ok, any, timeout | :hibernate} |
    {:backoff, timeout, any} | {:backoff, timeout, any, timeout | :hibernate} |
    {:stop, any, any}

  @callback handle_disconnect(any, any) ::
    {:connect, any, any} |
    {:backoff, timeout, any} | {:backoff, timeout, any, timeout | :hibernate} |
    {:noconnect, any} | {:noconnect, any, timeout | :hibernate} |
    {:stop, any, any}

  @doc """
  Invokes a user defined `handle_in/2` function, if defined.

  This function should be called by an adapter when a message arrives but
  should be handled by the user module.

  Returning `{:dispatch, msg, state}` will dispatch the message
  to all installed responders.

  Returning `{:send, {msg, text}, state}`, `{:reply, {msg, text}, state}`,
  or `{:emote, {msg, text}, state}` will send the message directly to the
  adapter without dispatching to any responders.

  Returning `{:noreply, state}` will ignore the message.
  """
  @callback handle_in(Hedwig.Message.t | any, any) ::
    {:noreply, any} |
    {:dispatch, Hedwig.Message.t, any} |
    {:send | :reply | :emote, {Hedwig.Message.t, String.t}, any}

  @doc """
  Called when the robot process is first started. `start_link/3` will block
  until it returns.

  Returning `{:ok, state}` will cause `start_link/3` to return
  `{:ok, pid}` and the process to enter its loop with state `state`.

  Returning `{:ok, state, timeout}` is similar to `{:ok, state}`
  except `handle_info(:timeout, state)` will be called after `timeout` if no
  message arrives.

  Returning `{:ok, state, :hibernate}` is similar to
  `{:ok, state}` except the process is hibernated awaiting a message.

  Returning `:ignore` will cause `start_link/3` to return `:ignore` and the
  process will exit normally without entering the loop or calling
  `terminate/2`.

  Returning `{:stop, reason}` will cause `start_link/3` to return
  `{:error, reason}` and the process to exit with reason `reason` without
  entering the loop or calling `terminate/2`.
  """
  @callback init(any) ::
    {:ok, any} |
    {:ok, any, timeout | :hibernate} |
    :ignore |
    {:stop, any}

  @doc """
  Called when the process receives a call message sent by `call/3`. This
  callback has the same arguments as the `GenServer` equivalent and the
  `:reply`, `:noreply` and `:stop` return tuples behave the same.
  """
  @callback handle_call(any, {pid, any}, any) ::
    {:reply, any, any} |
    {:reply, any, any, timeout | :hibernate} |
    {:noreply, any} |
    {:noreply, any, timeout | :hibernate} |
    {:stop, any, any} |
    {:stop, any, any, any}

  @doc """
  Called when the process receives a cast message sent by `cast/3`. This
  callback has the same arguments as the `GenServer` equivalent and the
  `:noreply` and `:stop` return tuples behave the same. However
  there are two additional return values:
  """
  @callback handle_cast(any, any) ::
    {:noreply, any} |
    {:noreply, any, timeout | :hibernate} |
    {:stop, any, any}

  @doc """
  Called when the process receives a message that is not a call or cast. This
  callback has the same arguments as the `GenServer` equivalent and the `:noreply`
  and `:stop` return tuples behave the same.
  """
  @callback handle_info(any, any) ::
    {:noreply, any} |
    {:noreply, any, timeout | :hibernate} |
    {:disconnect | :connect, any, any} |
    {:stop, any, any}

  @doc """
  This callback is the same as the `GenServer` equivalent and is used to change
  the state when loading a different version of the callback module.
  """
  @callback code_change(any, any, any) :: {:ok, any}

  @doc """
  This callback is the same as the `GenServer` equivalent and is called when the
  process terminates. The first argument is the reason the process is about
  to exit with.
  """
  @callback terminate(any, any) :: any

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Hedwig.Robot

      {otp_app, adapter, config} = Hedwig.Robot.Config.compile_config(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config config

      def __adapter__ do
        @adapter
      end

      def config(opts \\ []) do
        {:ok, config} = Hedwig.Robot.Config.runtime_config(:runtime, __MODULE__, @otp_app, opts)
        config
      end

      def child_spec(opts) do
        %{id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker}
      end

      def start_link(opts \\ []) do
        Hedwig.Robot.start_link(__MODULE__, config(opts))
      end

      # The default implementations of init/1, handle_call/3, handle_info/2,
      # handle_cast/2, terminate/2 and code_change/3 have been taken verbatim
      # from Elixir's GenServer default implementation.

      @doc false
      def init(args) do
        {:ok, args}
      end

      @doc false
      def handle_call(msg, _from, state) do
        # We do this to trick dialyzer to not complain about non-local returns.
        reason = {:bad_call, msg}
        case :erlang.phash2(1, 1) do
          0 -> exit(reason)
          1 -> {:stop, reason, state}
        end
      end

      @doc false
      def handle_cast(msg, state) do
        # We do this to trick dialyzer to not complain about non-local returns.
        reason = {:bad_cast, msg}
        case :erlang.phash2(1, 1) do
          0 -> exit(reason)
          1 -> {:stop, reason, state}
        end
      end

      @doc false
      def handle_info(_msg, state) do
        {:noreply, state}
      end

      @doc false
      def terminate(_reason, _state) do
        :ok
      end

      @doc false
      def code_change(_old, state, _extra) do
        {:ok, state}
      end

      # Hedwig.Robot specific callbacks

      @doc false
      def handle_connect(state, _timeout \\ 5000) do
        {:ok, state}
      end

      @doc false
      def handle_disconnect(_reason, state) do
        {:reconnect, state}
      end

      @doc false
      def handle_in(msg, state) do
        case msg do
          %Hedwig.Message{} ->
            {:dispatch, msg, state}
          _ ->
            {:noreply, state}
        end
      end

      defoverridable [
        {:code_change, 3},
        {:handle_call, 3},
        {:handle_cast, 2},
        {:handle_connect, 1},
        {:handle_connect, 2},
        {:handle_disconnect, 2},
        {:handle_in, 2},
        {:handle_info, 2},
        {:init, 1},
        {:start_link, 0},
        {:start_link, 1},
        {:terminate, 2}
      ]
    end
  end

  @doc """
  Starts a `Hedwig.Robot` process linked to the current process.

  This function is used to start a `Hedwig.Robot` process in a supervision tree.

  The process will be started by calling `init/1` in the callback module with
  the given argument.

  This function will return after `init/1` has returned in the spawned process.
  The return values are controlled by the `init/1` callback.

  See `GenServer.start_link/3` for more information.
  """
  @spec start_link(module, any, GenServer.options) :: GenServer.on_start
  def start_link(mod, args, opts \\ []) do
    start(mod, args, opts, :link)
  end

  @doc """
  Starts a `Hedwig.Robot` process without links (outside of a supervision tree).

  See `start_link/3` for more information.
  """
  @spec start(module, any, GenServer.options) :: GenServer.on_start
  def start(mod, args, opts \\ []) do
    start(mod, args, opts, :nolink)
  end

  @doc """
  Synchronously stops the server with the given `reason`.
  The `c:terminate/2` callback of the given `server` will be invoked before
  exiting. This function returns `:ok` if the server terminates with the
  given reason; if it terminates with another reason, the call exits.
  This function keeps OTP semantics regarding error reporting.
  If the reason is any other than `:normal`, `:shutdown` or
  `{:shutdown, _}`, an error report is logged.
  """
  @spec stop(robot, reason :: term, timeout) :: :ok
  def stop(robot, reason \\ :normal, timeout \\ :infinity) do
    :gen.stop(robot, reason, timeout)
  end

  @doc """
  Sends a synchronous call to the `Hedwig.Robot` process and waits for a reply.

  See `GenServer.call/2` for more information.
  """
  defdelegate call(robot, msg), to: :gen_server

  @doc """
  Sends a synchronous request to the `Hedwig.Robot` process and waits for a reply.

  See `GenServer.call/3` for more information.
  """
  defdelegate call(robot, msg, timeout), to: :gen_server

  @doc """
  Sends a asynchronous request to the `Hedwig.Robot` process.

  See `GenServer.cast/2` for more information.
  """
  defdelegate cast(robot, msg), to: GenServer

  @doc """
  Send a message via the robot.
  """
  def send(pid, msg) do
    cast(pid, {:send, msg})
  end

  @doc """
  Send a reply message via the robot.
  """
  def reply(pid, msg) do
    cast(pid, {:reply, msg})
  end

  @doc """
  Send an emote message via the robot.
  """
  def emote(pid, msg) do
    cast(pid, {:emote, msg})
  end

  @doc """
  Get the name of the robot.
  """
  def name(pid) do
    call(pid, :name)
  end

  @doc """
  Get the list of the robot's responders.
  """
  def responders(pid) do
    call(pid, :responders)
  end

  @doc """
  Invokes a user defined `handle_connect/1` function, if defined.

  If the user has defined an `handle_connect/1` in the robot module, it will be
  called with the robot's state. It is expected that the function return
  `{:ok, state}` or `{:stop, reason, state}`.
  """
  @spec handle_connect(pid, integer) :: :ok
  def handle_connect(robot, timeout \\ 5000) do
    call(robot, :handle_connect, timeout)
  end

  @doc """
  Invokes a user defined `handle_disconnect/1` function, if defined.

  If the user has defined an `handle_disconnect/1` in the robot module, it will be
  called with the robot's state. It is expected that the function return
  `{:reconnect, state}` `{:reconnect, integer, state}`, or `{:disconnect, reason, state}`.
  """
  @spec handle_disconnect(pid, any, integer) :: :reconnect | {:reconnect, integer} | {:disconnect, any}
  def handle_disconnect(robot, reason, timeout \\ 5000) do
    call(robot, {:handle_disconnect, reason}, timeout)
  end

  @doc """
  Invokes a user defined `handle_in/2` function, if defined.

  This function should be called by an adapter when a message arrives but
  should be handled by the user module.

  Returning `{:dispatch, msg, state}` will dispatch the message
  to all installed responders.

  Returning `{:send, {msg, text}, state}`, `{:reply, {msg, text}, state}`,
  or `{:emote, {msg, text}, state}` will send the message directly to the
  adapter without dispatching to any responders.

  Returning `{:noreply, state}` will ignore the message.
  """
  @spec handle_in(pid, any) :: :ok
  def handle_in(robot, msg) do
    cast(robot, {:handle_in, msg})
  end

  @doc false
  def code_change(old_vsn, %{mod: mod, mod_state: mod_state} = state, extra) do
    try do
      apply(mod, :code_change, [old_vsn, mod_state, extra])
    catch
      :throw, value ->
        exit({{:nocatch, value}, System.stacktrace()})
    else
      {:ok, mod_state} ->
        {:ok, %{state | mod_state: mod_state}}
    end
  end

  @doc false
  def terminate(reason, %{mod: mod, mod_state: mod_state, raise: nil}) do
    apply(mod, :terminate, [reason, mod_state])
  end
  def terminate(stop, %{raise: {class, reason, stack}} = state) do
    %{mod: mod, mod_state: mod_state} = state
    try do
      apply(mod, :terminate, [stop, mod_state])
    catch
      :throw, value ->
        :erlang.raise(:error, {:nocatch, value}, System.stacktrace())
    else
      _ when stop in [:normal, :shutdown] ->
        :ok
      _ when tuple_size(stop) == 2 and elem(stop, 0) == :shutdown ->
        :ok
      _ ->
        :erlang.raise(class, reason, stack)
    end
  end

  defp start(mod, args, opts, link) do
    case Keyword.pop(opts, :name) do
      {nil, opts} ->
        :gen.start(__MODULE__, link, mod, args, opts)
      {name, opts} when is_atom(name) ->
        :gen.start(__MODULE__, link, {:local, name}, mod, args, opts)
      {{:global, _} = name, opts} ->
        :gen.start(__MODULE__, link, name, mod, args, opts)
      {{:via, _, _} = name, opts} ->
        :gen.start(__MODULE__, link, name, mod, args, opts)
    end
  end

  ##############################
  # :gen & :proc_lib callbacks #
  ##############################

  @doc false
  def init_it(starter, _, name, mod, args, opts) do
    Process.put(:"$initial_call", {mod, :init, 1})
    try do
      apply(mod, :init, [args])
    catch
      :exit, reason ->
        init_stop(starter, name, reason)
      :error, reason ->
        init_stop(starter, name, {reason, System.stacktrace()})
      :throw, value ->
        reason = {{:notcatch, value}, System.stacktrace()}
        init_stop(starter, name, reason)
    else
      {:ok, mod_state} ->
        init_ack(starter)
        enter_loop(mod, nil, mod_state, name, opts, :infinity)
      {:ok, mod_state, timeout} ->
        init_ack(starter)
        enter_loop(mod, nil, mod_state, name, opts, timeout)
      :ignore ->
        _ = unregister(starter)
        init_ack(starter, :ignore)
        exit(:normal)
      {:stop, reason} ->
        init_stop(starter, name, reason)
      other ->
        init_stop(starter, name, {:bad_return_value, other})
    end
  end

  defp init_ack(pid),
    do: :proc_lib.init_ack(pid, {:ok, self()})
  defp init_ack(pid, reply),
    do: :proc_lib.init_ack(pid, reply)

  defp init_stop(starter, name, reason) do
    _ = unregister(name)
    :proc_lib.init_ack(starter, {:error, reason})
    exit(reason)
  end

  defp unregister(name) when name === self(), do: :ok
  defp unregister({:local, name}), do: Process.unregister(name)
  defp unregister({:global, name}), do: :global.unregister_name(name)
  defp unregister({:via, mod, name}), do: apply(mod, :unregister_name, [name])

  @doc false
  def enter_loop(mod, backoff, mod_state, name, opts, :hibernate) do
    args = [mod, backoff, mod_state, name, opts, :infinity]
    :proc_lib.hibernate(__MODULE__, :enter_loop, args)
  end
  def enter_loop(mod, backoff, mod_state, name, opts, timeout) when name === self() do
    state = init_state(backoff, mod, mod_state, opts)
    :gen_server.enter_loop(__MODULE__, opts, state, timeout)
  end
  def enter_loop(mod, backoff, mod_state, name, opts, timeout) do
    state = init_state(backoff, mod, mod_state, opts)
    :gen_server.enter_loop(__MODULE__, opts, state, name, timeout)
  end

  defp init_state(backoff, mod, mod_state, opts) do
    aka = Keyword.get(mod_state, :aka)
    name = Keyword.get(mod_state, :name)

    {adapter_mod, mod_state} = Keyword.pop(mod_state, :adapter)
    {responders, mod_state} = Keyword.pop(mod_state, :responders, [])

    unless responders == [] do
      cast(self(), {:install_responders, responders})
    end

    {:ok, adapter} = Hedwig.Adapter.start_link(adapter_mod, mod_state)
    {:ok, responder_sup} = Hedwig.Responder.Supervisor.start_link()

    %Hedwig.Robot{
      adapter: adapter,
      aka: aka,
      backoff: backoff,
      name: name,
      mod: mod,
      mod_state: mod_state,
      opts: opts,
      responder_sup: responder_sup,
      responders: responders}
  end

  @doc false
  def init(_) do
    {:stop, __MODULE__}
  end

  @doc false
  def handle_call(:name, _from, %{name: name} = state) do
    {:reply, name, state}
  end

  def handle_call(:responders, _from, %{responders: responders} = state) do
    {:reply, responders, state}
  end

  def handle_call(:handle_connect, _from, %{mod: mod, mod_state: mod_state} = state) do
    case apply(mod, :handle_connect, [mod_state]) do
      {:ok, mod_state} ->
        {:reply, :ok, %{state | mod_state: mod_state}}
      {:stop, reason, mod_state} ->
        {:stop, reason, %{state | mod_state: mod_state}}
    end
  end

  def handle_call({:handle_disconnect, reason}, _from, %{mod: mod, mod_state: mod_state} = state) do
    case apply(mod, :handle_disconnect, [reason, mod_state]) do
      {:reconnect, mod_state} ->
        {:reply, :reconnect, %{state | mod_state: mod_state}}
      {:reconnect, timer, mod_state} ->
        {:reply, {:reconnect, timer}, %{state | mod_state: mod_state}}
      {:disconnect, reason, mod_state} ->
        {:stop, reason, {:disconnect, reason}, %{state | mod_state: mod_state}}
    end
  end

  def handle_call(msg, from, %{mod: mod, mod_state: mod_state} = state) do
    try do
      apply(mod, :handle_call, [msg, from, mod_state])
    catch
      :throw, error ->
        :erlang.raise(:error, {:nocatch, error}, System.stacktrace())
    else
      {:noreply, mod_state} ->
        {:noreply, %{state | mod_state: mod_state}}
      {:noreply, mod_state, _timeout_or_hibernate} ->
        {:noreply, %{state | mod_state: mod_state}}
      {:reply, reply, mod_state} ->
        {:reply, reply, %{state | mod_state: mod_state}}
      {:reply, _, mod_state, _} = reply ->
        put_elem(reply, 2, %{state | mod_state: mod_state})
      {:stop, _, mod_state} = stop ->
        put_elem(stop, 2, %{state | mod_state: mod_state})
      {:stop, _, _, mod_state} = stop ->
        put_elem(stop, 3, %{state | mod_state: mod_state})
      other ->
        {:stop, {:bad_return_value, other}, %{state | mod_state: mod_state}}
    end
  end

  @doc false
  def handle_cast({:send, msg}, %{adapter: adapter} = state) do
    Hedwig.Adapter.send(adapter, msg)
    {:noreply, state}
  end

  def handle_cast({:reply, msg}, %{adapter: adapter} = state) do
    Hedwig.Adapter.reply(adapter, msg)
    {:noreply, state}
  end

  def handle_cast({:emote, msg}, %{adapter: adapter} = state) do
    Hedwig.Adapter.emote(adapter, msg)
    {:noreply, state}
  end

  def handle_cast({:install_responders, responders}, %{aka: aka, name: name} = state) do
    for {module, opts} <- responders do
      args = [module, {aka, name, opts, self()}]
      Supervisor.start_child(state.responder_sup, args)
    end
    {:noreply, state}
  end

  def handle_cast({:handle_in, msg}, %{mod: mod, mod_state: mod_state, responder_sup: sup} = state) do
    case apply(mod, :handle_in, [msg, mod_state]) do
      {:dispatch, %Hedwig.Message{} = msg, mod_state} ->
        responders = Supervisor.which_children(sup)
        Hedwig.Responder.dispatch(msg, responders)
        {:noreply, %{state | mod_state: mod_state}}

      {:dispatch, _msg, mod_state} ->
        log_incorrect_return(:dispatch)
        {:noreply, %{state | mod_state: mod_state}}

      {fun, {%Hedwig.Message{} = msg, text}, mod_state} when fun in [:send, :reply, :emote] ->
        apply(Hedwig.Responder, fun, [msg, text])
        {:noreply, %{state | mod_state: mod_state}}

      {fun, {_msg, _text}, mod_state} when fun in [:send, :reply, :emote] ->
        log_incorrect_return(fun)
        {:noreply, %{state | mod_state: mod_state}}

      {:noreply, mod_state} ->
        {:noreply, %{state | mod_state: mod_state}}
    end
  end

  defp log_incorrect_return(atom) do
    require Logger
    Logger.warn """
    #{inspect atom} return value from `handle_in/2` only works with `%Hedwig.Message{}` structs.
    """
  end
end
