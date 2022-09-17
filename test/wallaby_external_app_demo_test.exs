defmodule WallabyExternalAppDemoTest do
  use ExUnit.Case
  doctest WallabyExternalAppDemo

  test "greets the world" do
    assert WallabyExternalAppDemo.hello() == :world
  end
end
