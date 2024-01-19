defmodule ElixirNifPeerExample.MathTest do
  use ExUnit.Case

  alias ElixirNifPeerExample.Math

  test "add/2" do
    assert 3 == Math.add(1, 2)
  end
end
