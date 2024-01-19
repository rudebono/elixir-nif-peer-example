defmodule ElixirNifPeerExample.MathPeerPoolTest do
  use ExUnit.Case

  alias ElixirNifPeerExample.MathPeerPool

  setup do
    {:ok, _pid} = MathPeerPool.start_link()
    :ok
  end

  test "add/2" do
    assert 3 == MathPeerPool.add(1, 2)
  end
end
