defmodule ElixirNifPeerExample.MathPeerPoolTest do
  use ExUnit.Case

  alias ElixirNifPeerExample.MathPeerPool

  setup_all do
    {:ok, _pid} = MathPeerPool.start_link()
    :ok
  end

  test "add/2" do
    assert 3 == MathPeerPool.add(1, 2)
  end

  test "unsafe_add/2" do
    assert true == MathPeerPool.unsafe_add(1, 2) in [3, :timeout]
  end
end
