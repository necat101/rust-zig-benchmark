use std::collections::HashMap;
use std::env;
use std::time::Instant;

fn main() {
    let n = env::args()
        .nth(1)
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(1_000_000);
    
    let mut map = HashMap::with_capacity(n);
    
    // Insertion benchmark
    let start = Instant::now();
    for i in 0..n {
        map.insert(i, i * 2);
    }
    let insert_duration = start.elapsed();
    
    // Lookup benchmark
    let start = Instant::now();
    let mut sum = 0usize;
    for i in 0..n {
        if let Some(val) = map.get(&i) {
            sum += val;
        }
    }
    let lookup_duration = start.elapsed();
    
    // Mixed workload
    let start = Instant::now();
    for i in 0..n/10 {
        map.insert(n + i, i);
        map.remove(&(i * 2));
        map.get(&(i * 3 % n));
    }
    let mixed_duration = start.elapsed();
    
    println!("HashMap benchmark ({} items):", n);
    println!("  Insert:  {:?} ({:.0} ops/sec)", 
             insert_duration, 
             n as f64 / insert_duration.as_secs_f64());
    println!("  Lookup:  {:?} ({:.0} ops/sec)", 
             lookup_duration,
             n as f64 / lookup_duration.as_secs_f64());
    println!("  Mixed:   {:?}", mixed_duration);
    println!("  Sum:     {} (verification)", sum);
    println!("  Final size: {}", map.len());
}