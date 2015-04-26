use Mix.Config

config :sasl,
  sasl_error_logger: false

config :logger, :console,
  level: :debug

config :hedwig,
  clients: []

config :ejabberd,
  file: "config/ejabberd.yml",
  log_path: 'logs/ejabberd.log'

config :mnesia,
  dir: 'mnesia'

