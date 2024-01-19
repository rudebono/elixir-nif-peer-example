defmodule ElixirNifPeerExample.MathPeer do
  alias ElixirNifPeerExample.Math

  def add(a, b) do
    {:ok, peer, _peername} = :peer.start_link(%{connection: :standard_io})

    try do
      :ok = :peer.call(peer, :code, :add_paths, [:code.get_path()])
      :peer.call(peer, Math, :add, [a, b])
    after
      :peer.stop(peer)
    end
  end
end
