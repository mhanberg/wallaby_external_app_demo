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
