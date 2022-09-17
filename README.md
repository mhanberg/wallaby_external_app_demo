# WallabyExternalAppDemo

This is an example project demonstrating how you might reliably start another web application and run tests on it.

In the test_helper.exs file, we'll find the following code.

```elixir
Task.start_link(fn ->
  System.cmd("mix", ["run", "--no-halt"], cd: "../wallaby_plug_demo")
end)

# wait for server to boot up
wait = fn wait ->
  case :gen_tcp.connect('localhost', 4000, [:binary, packet: 0]) do
    {:ok, socket} ->
      :gen_tcp.close(socket)

    _ ->
      Process.sleep(50)
      wait.(wait)
  end
end

wait.(wait)

ExUnit.start()
```

First we start the other project in a Task, allowing it to start but allowing the test_helper script to move forward.

We then want to wait until the application has booted up. We do then by trying to make a tcp connection to the server, and try and try again until we succeed. 

A neat observation here to how we perform recursion using a lambda, by passing the function to itself.

That's (mostly) all there is to it! We have one nuance that was required for this setup, but that may not be necessary in yours.

In the app we are starting, I needed to make sure that the OS process would end when are tests were over. To do this, I needed to make that application listen to stdin and shut down the program when stdin closed.

I accomplished this with the following code.

```elixir
defmodule WallabyPlugDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # 👇👇👇👇👇👇👇
    Task.start(fn ->
      # read until eof
      IO.read(:eof)

      # then shut down the system
      System.halt(0)
    end)
    # 👆👆👆👆👆👆👆 

    children = [
      {Bandit, plug: WallabyPlugDemo.Plug, scheme: :http, options: [port: 4000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WallabyPlugDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```
