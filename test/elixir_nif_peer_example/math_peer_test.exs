defmodule ElixirNifPeerExample.MathPeerTest do
  use ExUnit.Case

  alias ElixirNifPeerExample.MathPeer

  test "add/2" do
    assert 3 == MathPeer.add(1, 2)
  end

  test "unsafe_add/2" do
    assert true == MathPeer.unsafe_add(1, 2) in [3, :timeout]
  end
end
