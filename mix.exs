defmodule ElixirNifPeerExample.MixProject do
  use Mix.Project

  def project() do
    [
      app: :elixir_nif_peer_example,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application() do
    [
      extra_applications: [:logger],
      mod: {ElixirNifPeerExample.Application, []}
    ]
  end

  defp deps() do
    [
      {:benchfella, "~> 0.3.0", only: :dev},
      {:rustler, "~> 0.30.0", runtime: false},
      {:nimble_pool, "~> 1.0"}
    ]
  end
end
