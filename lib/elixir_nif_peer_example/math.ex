defmodule ElixirNifPeerExample.Math do
  use Rustler, otp_app: :elixir_nif_peer_example, crate: "elixir_nif_peer_example_math"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def unsafe_add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
