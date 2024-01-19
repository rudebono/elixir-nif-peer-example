defmodule ElixirNifPeerExample.MathPeerPool do
  @behaviour NimblePool

  alias ElixirNifPeerExample.Math

  @impl NimblePool
  def init_worker(pool_state) do
    {:ok, peer, _peername} = :peer.start_link(%{connection: :standard_io})
    :ok = :peer.call(peer, :code, :add_paths, [:code.get_path()])
    {:ok, peer, pool_state}
  end

  @impl NimblePool
  def handle_checkout(:checkout, {_pid, _ref}, peer, pool_state) do
    {:ok, peer, peer, pool_state}
  end

  @impl NimblePool
  def handle_checkin(:ok, _from, peer, pool_state) do
    {:ok, peer, pool_state}
  end

  def handle_checkin(:exit, _from, _peer, pool_state) do
    {:remove, :exit, pool_state}
  end

  @impl NimblePool
  def terminate_worker(_reason, peer, pool_state) do
    :peer.stop(peer)
    {:ok, pool_state}
  end

  def start_link() do
    children = [{NimblePool, worker: {__MODULE__, []}, name: __MODULE__}]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  def add(a, b) do
    NimblePool.checkout!(__MODULE__, :checkout, fn {_pid, _ref}, peer ->
      {:peer.call(peer, Math, :add, [a, b]), :ok}
    end)
  end
end
