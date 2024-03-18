[![Check](https://github.com/rudebono/elixir-nif-peer-example/actions/workflows/check.yml/badge.svg)](https://github.com/rudebono/elixir-nif-peer-example/actions/workflows/check.yml) 

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rudebono/elixir-nif-peer-example)


# Introduction to Safe Erlang NIFs

Explore integrating high-performance C functions into Elixir applications through Native Implemented Functions (NIFs) while ensuring system resilience via the `:peer` module. This methodology balances performance with safety, enabling developers to harness the speed of C code execution within the robust, fault-tolerant environment of the BEAM virtual machine.

## 1. What are NIFs?

Native Implemented Functions (NIFs) allow Elixir and Erlang code to call functions written in C or Rust, treating them as native functions. Essential for performance-critical operations, this feature comes with the caveat that errors in native code can potentially crash the BEAM VM, affecting the system's reliability.

### 1.1 Safe NIF Example and Execution

**Code Sample:**

Elixir:
```elixir
defmodule ElixirNifPeerExample.Math do
  use Rustler, otp_app: :elixir_nif_peer_example, crate: "elixir_nif_peer_example_math"

  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
```

Rust:
```rust
#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

rustler::init!("Elixir.ElixirNifPeerExample.Math", [add]);
```

**Memory Mapping Across Two Erlang Nodes:**

To illustrate the independent loading of `libelixir_nif_peer_example_math.so` in distributed Erlang environments, we use the `pmap` command to inspect the memory mapping of the NIF-loaded process on two separate nodes.

On the first node:

```sh
@rudebono ➜ ~/workspace (main) $ iex --sname node1 -S mix
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.16.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(node1@47f0cae28324)1> ElixirNifPeerExample.Math.add(1, 1)
2
```

Output might include lines indicating the NIF library, showing its memory allocation:

```sh
@rudebono ➜ ~/workspace (main) $ pmap 19300
19300:   /usr/local/lib/erlang/erts-14.2.1/bin/beam.smp -- -root /usr/local/lib/erlang -bindir /usr/local/lib/erlang/erts-14.2.1/bin -progname erl -- -home /home/vscode -- -noshell -elixir_root /usr/local/lib/elixir/bin/../lib -pa /usr/local/lib/elixir/bin/../lib/elixir/ebin -s elixir start_iex -elixir ansi_enabled true -user elixir -sname node2 -extra --no-halt +iex -S mix
00007fecf0df1000     24K r---- libelixir_nif_peer_example_math.so
00007fecf0df7000    284K r-x-- libelixir_nif_peer_example_math.so
00007fecf0e3e000     68K r---- libelixir_nif_peer_example_math.so
00007fecf0e4f000     16K r---- libelixir_nif_peer_example_math.so
00007fecf0e53000      4K rw--- libelixir_nif_peer_example_math.so
```

On the second node:

```sh
@rudebono ➜ ~/workspace (main) $ iex --sname node2 -S mix
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.16.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(node2@47f0cae28324)1> ElixirNifPeerExample.Math.add(1, 1)
2
```

Output for the second node, similarly showing `libelixir_nif_peer_example_math.so` but with different memory addresses, confirms the NIF's separate allocation:

```sh
@rudebono ➜ ~/workspace (main) $ pmap 19157
19157:   /usr/local/lib

/erlang/erts-14.2.1/bin/beam.smp -- -root /usr/local/lib/erlang -bindir /usr/local/lib/erlang/erts-14.2.1/bin -progname erl -- -home /home/vscode -- -noshell -elixir_root /usr/local/lib/elixir/bin/../lib -pa /usr/local/lib/elixir/bin/../lib/elixir/ebin -s elixir start_iex -elixir ansi_enabled true -user elixir -sname node1 -extra --no-halt +iex -S mix
00007fd17c42d000     24K r---- libelixir_nif_peer_example_math.so
00007fd17c433000    284K r-x-- libelixir_nif_peer_example_math.so
00007fd17c47a000     68K r---- libelixir_nif_peer_example_math.so
00007fd17c48b000     16K r---- libelixir_nif_peer_example_math.so
00007fd17c48f000      4K rw--- libelixir_nif_peer_example_math.so
```

This demonstrates that even when the same NIF is used across different nodes, each instance is loaded into its own independent memory space, ensuring that operations in one node do not affect the stability or functionality of others.

### 1.2 Unsafe NIF Example and Execution

**Code Sample:**

Rust implementation showcasing a potential deadlock:

```rust
use rand::Rng;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

// This is an unsafe add function that may deadlock with a certain probability.
#[rustler::nif]
fn unsafe_add(a: i64, b: i64) -> i64 {
    let mutex1 = Arc::new(Mutex::new(0));
    let mutex2 = Arc::new(Mutex::new(0));

    let mutex1_clone = Arc::clone(&mutex1);
    let mutex2_clone = Arc::clone(&mutex2);

    let thread1 = thread::spawn(move || {
        let _lock1 = mutex1_clone.lock().unwrap();

        // There's a 50% chance of deadlock occurring.
        if rand::thread_rng().gen_bool(0.5) {
            thread::sleep(Duration::from_millis(1000));
        }

        let _lock2 = mutex2_clone.lock().unwrap();
    });

    let thread2 = thread::spawn(move || {
        let _lock2 = mutex2.lock().unwrap();
        let _lock1 = mutex1.lock().unwrap();
    });

    thread1.join().unwrap();
    thread2.join().unwrap();

    a + b
}

rustler::init!("Elixir.ElixirNifPeerExample.Math", [unsafe_add]);
```

**Execution:**

Highlighting the risk of deadlock through an interactive Elixir session:

```sh
@rudebono ➜ ~/workspace (main) $ iex --sname node3 -S mix
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.16.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(node3@47f0cae28324)1> ElixirNifPeerExample.Math.unsafe_add(1, 1)
2
iex(node3@47f0cae28324)2> ElixirNifPeerExample.Math.unsafe_add(2, 2)
deadlock!
```

## 2. The Peer Module

The `:peer` module facilitates code execution in separate, linked BEAM nodes, making it ideal for isolating unsafe NIF operations in controlled environments to mitigate risk to the main system.

### 2.1 Using the Peer Module for Safe NIF Execution

**Code Sample:**

```elixir
defmodule ElixirNifPeerExample.MathPeer do
  alias ElixirNifPeerExample.Math

  def unsafe_add(a, b) do
    {:ok, peer, _peername} = :peer.start_link(%{connection: :standard_io})
    try do
      :ok = :peer.call(peer, :code, :add_paths, [:code.get_path()]);
      :peer.call(peer, Math, :unsafe_add, [a, b])
    catch
      _kind, _reason ->
        :timeout
    after
      :peer.stop(peer)
    end
  end
end
```

**Execution:**

Demonstrating fault tolerance during an interactive session:

```sh
@rudebono ➜ ~/workspace (main) $ i

ex --sname node4 -S mix
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]

Interactive Elixir (1.16.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(node4@47f0cae28324)1> ElixirNifPeerExample.MathPeer.unsafe_add(1, 1)
2
iex(node4@47f0cae28324)2> ElixirNifPeerExample.MathPeer.unsafe_add(2, 2)
:timeout
```

## 3. Benchmark Results: Balancing Safety and Speed

Benchmarking various NIF usage strategies emphasizes the trade-offs between direct execution speed and the safety guaranteed by isolation. Direct NIF calls showcase optimal performance at the cost of fault tolerance, while peer nodes introduce overhead yet significantly enhance system resilience.

```sh
@rudebono ➜ ~/workspace (main) $ mix bench
Settings:
  duration:      1.0 s

## MathBench
[06:04:44] 1/3: add/2
## MathPeerBench
[06:04:50] 2/3: add/2
## MathPeerPoolBench
[06:04:54] 3/3: add/2

Finished in 11.86 seconds

## MathBench
benchmark iterations   average time 
add/2   100000000   0.05 µs/op
## MathPeerBench
benchmark iterations   average time 
add/2          10   195671.60 µs/op
## MathPeerPoolBench
benchmark iterations   average time 
add/2       10000   160.14 µs/op
```

## Conclusion

This strategy presents a method for incorporating C functions into Elixir applications, focusing on maintaining system resilience through the `:peer` module for isolating potentially unsafe NIF operations. It enables high-performance C code execution in a safe, fault-tolerant manner, supported by empirical evidence from memory management practices.
