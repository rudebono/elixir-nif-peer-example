defmodule MathPeerPoolBench do
  use Benchfella

  alias ElixirNifPeerExample.MathPeerPool

  setup_all do
    MathPeerPool.start_link()
  end

  teardown_all pid do
    Supervisor.stop(pid)
  end

  bench "add/2" do
    3 = MathPeerPool.add(1, 2)
  end
end
