# Optimized Benchmark Results - Fair Comparison

All Zig programs now use `std.heap.c_allocator` (libc malloc/free) to match Rust's system allocator.

## Results Summary

| Benchmark | Rust | Zig Optimized | Winner | Margin |
|-----------|------|---------------|--------|--------|
| **N-Body** (1M iter) | 0.055s | 0.065s | Rust | +18% |
| **Binary Trees** (depth 20) | 19.37s | 13.26s | **Zig** | **+46%** 🏆 |
| **Hash Table Insert** | 88ms | 90ms | Rust | +2% |
| **Hash Table Lookup** | 91ms | 69ms | **Zig** | **+32%** 🏆 |

## Detailed Results

### 1. N-Body Simulation
- **Rust**: 0.049-0.060s
- **Zig**: 0.059-0.070s
- **Analysis**: Rust's LLVM backend produces slightly better code for tight floating-point loops

### 2. Binary Trees (Depth 20)
**BEFORE Optimization:**
- Rust: 19.37s
- Zig (GPA): 179.34s ❌ (9.3x slower - unfair comparison)

**AFTER Optimization (both using libc):**
- Rust: 19.37s
- Zig: 13.26s ✅
- **Zig is 46% FASTER** with proper allocator!

**Lesson**: Allocator choice dominates this benchmark. GeneralPurposeAllocator has:
- Thread safety overhead
- Memory safety checks
- Leak detection
- Canaries and metadata
- Double-free detection

For production code, GPA is safer but slower. For benchmarks, use `c_allocator` or `ArenaAllocator`.

### 3. Hash Table (1M items)
- **Insert**: Rust 88ms vs Zig 90ms (essentially tied)
- **Lookup**: Rust 91ms vs Zig 69ms (Zig 32% faster)
- **Analysis**: 
  - Rust uses SipHash 1-3 (DoS resistant, slower)
  - Zig uses Wyhash (fast, non-cryptographic)
  - For non-adversarial workloads, Wyhash is better choice

## Key Takeaways

### 1. **Fair Comparison Requires Matching Configurations**
- Same allocator (libc malloc)
- Same optimization level (-O3 / ReleaseFast)
- Same target CPU
- Comparable algorithms

### 2. **No Universal Winner**
- **Zig wins**: Binary trees (+46%), Hash lookups (+32%)
- **Rust wins**: N-body (+18%), Hash inserts (+2%)
- **Tie**: Most differences are <20%

### 3. **Language Choice Should Consider**
Beyond raw speed:
- **Rust**: Memory safety, ecosystem, async/await, pattern matching
- **Zig**: Simplicity, C interop, compile-time execution, explicit control

### 4. **Optimization Matters**
Zig binary trees improved **13.5x** (179s → 13s) just by changing allocator:
```zig
// Slow (debug allocator)
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// Fast (system allocator)  
const allocator = std.heap.c_allocator; // + -lc flag
```

## Build Commands (Optimized)

```bash
# Rust
rustc -O -C target-cpu=native -C opt-level=3 file.rs

# Zig (with libc for fair comparison)
zig build-exe file.zig -O ReleaseFast -lc
```

## Conclusion

With **properly matched configurations**, Rust and Zig are **neck-and-neck** in performance:

- Differences are typically **<20%** in either direction
- Both compile to highly optimized native code via LLVM
- Choice should be based on language features, not microbenchmarks

The original HN discussion was correct: **both are excellent systems languages** with different trade-offs. Benchmarks should inform, not dictate, language choice.
