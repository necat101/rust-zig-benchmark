#!/bin/bash
set -e

echo "=== Rust vs Zig Performance Benchmark ==="
echo "Building and running n-body simulation..."
echo ""

# Set up environment
export PATH="$HOME/.cargo/bin:$HOME/.local/zig:$PATH"

cd "$(dirname "$0")"

echo "Compiling Rust version..."
. "$HOME/.cargo/env"
rustc -O -C target-cpu=native -C opt-level=3 nbody.rs -o nbody_rust

echo "Compiling Zig version..."
/home/ubuntu/.local/zig/zig build-exe nbody.zig -O ReleaseFast -femit-bin=nbody_zig

echo ""
echo "Running benchmarks (1,000,000 iterations)..."
echo ""

echo "--- Rust ---"
time ./nbody_rust 1000000

echo ""
echo "--- Zig ---"
time ./nbody_zig 1000000

echo ""
echo "=== Benchmark Complete ==="
