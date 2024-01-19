defmodule MathPeerBench do
  use Benchfella

  alias ElixirNifPeerExample.MathPeer

  bench "add/2" do
    3 = MathPeer.add(1, 2)
  end
end
