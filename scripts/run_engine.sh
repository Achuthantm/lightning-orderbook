#!/bin/bash
set -e

# 1. Setup data
echo "Checking for synthetic data..."
if [ ! -f "data/synthetic.itch" ]; then
    echo "Generating synthetic data..."
    python3 scripts/generate_itch.py
fi

# 2. Build engine
echo "Building benchmarks..."
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target bench_engine

# 3. Run benchmark
echo "Running engine benchmark (requires sudo for Apple Silicon performance counters)..."
sudo ./build/bench_engine data/synthetic.itch latency_engine.csv

# 4. Success message
echo "Benchmark completed. Results saved to latency_engine.csv"
