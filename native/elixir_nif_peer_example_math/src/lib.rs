use rand::Rng;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

// This is an unsafe add function that deadlocks with a certain probability.
#[rustler::nif]
fn unsafe_add(a: i64, b: i64) -> i64 {
    let mutex1 = Arc::new(Mutex::new(0));
    let mutex2 = Arc::new(Mutex::new(0));

    let mutex1_clone = Arc::clone(&mutex1);
    let mutex2_clone = Arc::clone(&mutex2);

    let thread1 = thread::spawn(move || {
        let _lock1 = mutex1_clone.lock().unwrap();

        // Deadlock occurs with a 50% probability.
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

rustler::init!("Elixir.ElixirNifPeerExample.Math", [add, unsafe_add]);
