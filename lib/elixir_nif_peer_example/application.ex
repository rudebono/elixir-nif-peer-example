defmodule ElixirNifPeerExample.Application do
  use Application

  # alias ElixirNifPeerExample.MathPeerPool

  @impl true
  def start(_type, _args) do
    children = [
      ###########
      # Warning #
      ###########
      #
      # The `MathPeerPool` module is executed with a simple `:peer` start options:
      #
      # :peer.start(%{connection: :standard_io})
      #
      # While this poses no issues during development,
      # if you run the app after performing mix release, you may encounter an error stating that the `boot_file` cannot be found.
      # This occurs because the `:peer` attempts to run the Released node instead of launching an empty Erlang node.
      # If you want to run an empty Erlang node,
      # please set the path to the empty Erlang node in the exec option of the `:peer`, as follows:
      #
      # :peer.start(%{connection: :standard_io, exec: '/usr/local/bin/erl'})
      #
      ###########
      # {NimblePool, worker: {MathPeerPool, []}, name: MathPeerPool}
    ]

    opts = [strategy: :one_for_one, name: ElixirNifPeerExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
