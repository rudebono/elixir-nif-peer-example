defmodule ElixirNifPeerExample.MathPeerTest do
  use ExUnit.Case

  alias ElixirNifPeerExample.MathPeer

  test "add/2" do
    assert 3 == MathPeer.add(1, 2)
  end
end
