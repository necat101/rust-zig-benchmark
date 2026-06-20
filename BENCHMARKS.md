# Extended Benchmark Results

## Binary Trees (Depth 20)
Classic allocation-heavy benchmark testing memory allocator performance.

### Results
| Implementation | Time | Relative |
|----------------|------|----------|
| Rust | 19.37s | 1.0x (baseline) |
| Zig (GPA) | 179.34s | 9.26x slower |

### Analysis
**Zig is 9x slower** due to allocator choice:
- **Rust**: Uses system allocator (malloc/free) - optimized for this workload
- **Zig**: Uses GeneralPurposeAllocator (GPA) - debug allocator with safety checks

The GPA has significant overhead:
- Memory safety checks
- Leak detection
- Thread safety
- Canaries and metadata

**To fix**: Use `ArenaAllocator` or `std.heap.c_allocator` in Zig for fair comparison.

## Hash Table (1M items)

### Results
| Operation | Rust | Zig | Winner |
|-----------|------|-----|--------|
| Insert | 102ms (9.79M ops/s) | 90ms (11.07M ops/s) | Zig (+13%) |
| Lookup | 104ms (9.62M ops/s) | 69ms (14.47M ops/s) | Zig (+50%) |
| Mixed | 29ms | 20ms | Zig (+45%) |

### Analysis
**Zig wins decisively** on hash table operations:
- 13% faster inserts
- 50% faster lookups  
- 45% faster mixed workload

Possible reasons:
1. **Hash function**: Different default hashers (Rust uses SipHash 1-3, Zig uses Wyhash)
2. **Table implementation**: Different growth strategies and memory layouts
3. **Allocator**: Both using system allocators here (fair comparison)

## N-Body Simulation (1M iterations)

### Results
| Implementation | Time | Relative |
|----------------|------|----------|
| Rust | 0.055s avg | 1.0x |
| Zig | 0.065s avg | 1.18x slower |

**Rust ~15% faster** - likely due to LLVM optimization differences.

## Summary

| Benchmark | Winner | Margin | Notes |
|-----------|--------|--------|-------|
| N-Body | Rust | +15% | Compute-bound, similar codegen |
| Binary Trees | Rust | +826% | Allocator mismatch (unfair) |
| Hash Table | Zig | +13-50% | Different hash algorithms |

### Key Takeaways

1. **Allocator choice matters enormously** - 9x difference in binary trees
2. **No clear overall winner** - Each language wins different benchmarks
3. **Implementation details dominate** - Hash function, allocator, etc. matter more than language
4. **Both are fast** - All benchmarks complete in reasonable time

### For Fair Comparison
To properly compare languages (not implementations):
- Use same allocator (system malloc)
- Use same hash function
- Use same optimization levels
- Test multiple workloads
- Consider real-world usage patterns, not just microbenchmarks
