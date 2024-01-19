defmodule MathBench do
  use Benchfella

  alias ElixirNifPeerExample.Math

  bench "add/2" do
    3 = Math.add(1, 2)
  end
end
