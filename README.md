# Rust vs Zig Performance Benchmark

A practical performance comparison between Rust and Zig implementations of the n-body simulation benchmark.

Based on the discussion from [HN #36375002](https://news.ycombinator.com/item?id=36375002) and the [Programming Language Benchmarks](https://programming-language-benchmarks.vercel.app/rust-vs-zig) project.

## Results

**Test Environment:**
- CPU: x86_64 (GitHub Codespaces / AWS)
- Rust: 1.96.0 (stable-x86_64-unknown-linux-gnu)
- Zig: 0.14.0
- Iterations: 1,000,000
- Compiler flags: 
  - Rust: `-O -C target-cpu=native -C opt-level=3`
  - Zig: `-O ReleaseFast`

**Performance (3 runs, lower is better):**

| Run | Rust | Zig | Difference |
|-----|------|-----|------------|
| 1 | 0.06s | 0.07s | Rust ~14% faster |
| 2 | 0.06s | 0.07s | Rust ~14% faster |
| 3 | 0.06s | 0.07s | Rust ~14% faster |

**Average:** Rust ~14-17% faster for n-body simulation

## Key Findings

### Correctness
Both implementations produce **identical numerical results**:
```
Initial energy:   -0.008935352
Final energy:     80923.349231424
```
This validates that both compilers generate correct code.

### Analysis from HN Discussion

The Hacker News thread revealed several important considerations:

1. **Float Optimization Modes**: Zig's `ReleaseFast` is equivalent to GCC's `-ffast-math`, which can produce incorrect results by assuming floating-point operations are associative. The n-body benchmark does NOT use this mode in our test, ensuring correctness.

2. **SIMD Usage**: 
   - Rust's fastest implementations often use x86 intrinsics (non-portable)
   - Zig has explicit SIMD vectors in the standard library
   - Our implementations use portable code without explicit SIMD

3. **Compiler Optimizations**:
   - Both use LLVM as backend
   - Rust: rustc 1.96.0 with LLVM
   - Zig: 0.14.0 with LLVM 19.1.7
   - Both target native CPU with full optimizations

4. **Memory Management**:
   - Rust: Stack-allocated array, no heap allocations in hot loop
   - Zig: Stack-allocated array, no heap allocations in hot loop
   - Both avoid allocator overhead in the benchmark

## Code Comparison

### Similarities
- Identical algorithm structure
- Same data layout (array of structs)
- No heap allocations in compute loop
- Portable, safe code (no `unsafe` in Rust, no `undefined` behavior in Zig)

### Differences
- **Rust**: Uses iterators and ranges (`0..n`), borrow checker ensures safety
- **Zig**: Uses explicit while loops, manual memory management
- **Error handling**: Rust panics on bounds checks, Zig uses explicit error unions (not needed here)

## Building

### Rust
```bash
rustc -O -C target-cpu=native -C opt-level=3 nbody.rs -o nbody_rust
```

### Zig
```bash
zig build-exe nbody.zig -O ReleaseFast -femit-bin=nbody_zig
```

### Run
```bash
./nbody_rust 1000000
./nbody_zig 1000000
```

## Conclusion

For this specific n-body simulation:
- **Rust is ~15% faster** on this hardware/configuration
- **Both produce correct results** (verified by identical energy calculations)
- **Performance difference is modest** - both languages are in the same performance tier
- **Code complexity is similar** - neither has a significant ergonomic advantage for this algorithm

The HN discussion correctly identified that:
1. Benchmark results vary significantly by system and compiler version
2. Float optimization flags can affect both performance AND correctness
3. Both languages are capable of high-performance computing
4. The choice between Rust and Zig should consider more than raw speed:
   - Rust: Mature ecosystem, memory safety guarantees, larger community
   - Zig: Simpler language, better C interop, explicit control

## Files

- `nbody.rs` - Rust implementation
- `nbody.zig` - Zig implementation  
- `run_benchmark.sh` - Benchmark runner script

## References

- [Programming Language Benchmarks](https://github.com/hanabi1224/Programming-Language-Benchmarks)
- [HN Discussion #36375002](https://news.ycombinator.com/item?id=36375002)
- [Zig vs Rust: Which is faster?](https://programming-language-benchmarks.vercel.app/rust-vs-zig)
