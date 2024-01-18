defmodule ElixirNifPeerExampleTest do
  use ExUnit.Case
  doctest ElixirNifPeerExample

  test "greets the world" do
    assert ElixirNifPeerExample.hello() == :world
  end
end
