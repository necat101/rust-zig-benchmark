# Benchmark Results Summary

## Test Configuration
- **Date**: 2026-06-20
- **System**: x86_64 Linux (AWS/GitHub Codespaces)
- **Iterations**: 1,000,000 n-body simulation steps

## Compiler Versions
- **Rust**: 1.96.0 (stable)
- **Zig**: 0.14.0 (with LLVM 19.1.7)

## Build Commands
```bash
# Rust
rustc -O -C target-cpu=native -C opt-level=3 nbody.rs -o nbody_rust

# Zig  
zig build-exe nbody.zig -O ReleaseFast -femit-bin=nbody_zig
```

## Results

### Performance (3 runs)
| Metric | Rust | Zig | Winner |
|--------|------|-----|--------|
| Run 1 | 0.049s | 0.059s | Rust (+17% faster) |
| Run 2 | 0.060s | 0.070s | Rust (+14% faster) |
| Run 3 | 0.060s | 0.070s | Rust (+14% faster) |

### Correctness Verification
Both implementations produce **bit-identical results**:
- Initial energy: `-0.008935352`
- Final energy: `80923.349231424`

### Binary Sizes
- Rust: 4.5 MB (statically linked with Zig's libc)
- Zig: 2.2 MB

## Analysis

### Why Rust Was Faster
1. **LLVM optimizations**: Rust's mature optimizer may have better inlining decisions
2. **Bounds checking**: Rust's bounds checks were likely elided by the optimizer
3. **Code generation**: Slight differences in loop unrolling or vectorization

### Why Results Differ from HN Discussion
The HN thread showed mixed results with Zig sometimes winning. Factors:
1. **Different benchmarks**: HN discussed multiple algorithms (nbody, binarytrees, etc.)
2. **Compiler versions**: Results vary significantly across versions
3. **Hardware differences**: CPU architecture matters greatly
4. **Optimization flags**: Zig's ReleaseFast vs ReleaseSafe, Rust's opt-levels

### Key Takeaway
Both languages deliver **excellent performance** (sub-100ms for 1M iterations). The ~15% difference is:
- Noticeable in benchmarks
- Likely irrelevant in real applications
- Subject to change with compiler updates

Choose based on:
- **Rust**: If you need the ecosystem, memory safety, and mature tooling
- **Zig**: If you want simplicity, explicit control, and seamless C interop
