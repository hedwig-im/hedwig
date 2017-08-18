config = [adapter: Hedwig.Adapters.Test, name: "hedwig", aka: "/"]
Application.put_env(:hedwig, Hedwig.TestRobot, config)
ExUnit.start()
