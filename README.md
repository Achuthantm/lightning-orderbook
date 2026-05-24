# Lightning Orderbook

Lightning Orderbook is a high-performance, single-threaded matching engine written in C++20. It is designed for low-latency trade execution, featuring a NASDAQ ITCH 5.0 binary parser and a high-precision benchmarking suite.

## Key Features

- **Low-Latency Architecture**: Optimized for cache locality and minimal branch misprediction.
- **NASDAQ ITCH 5.0 Parser**: Efficient callback-based binary parser for market data replay.
- **Cache-Optimized Data Structures**:
  - **Flat Map Order Book**: Uses `std::vector` to store price levels, maximizing cache hits during book traversal.
  - **Intrusive Linked Lists**: Orders at each price level are managed via an intrusive doubly-linked list for $O(1)$ cancellations and FIFO time priority.
- **Memory Management**: Employs a custom `OrderPool` (Arena allocator) to eliminate heap fragmentation and minimize allocation overhead during hot paths.
- **Fixed-Point Arithmetic**: Prices are handled as `int64_t` with 4 decimal places (scaled by 10,000) to ensure deterministic precision without floating-point jitter.
- **High-Precision Benchmarking**: Measures execution latency in CPU clock cycles using hardware performance counters (specifically optimized for Apple Silicon via `kperf`), calibrated to nanoseconds.

## Project Structure

```text
├── include/           # Core engine headers (matching logic, data structures)
├── src/               # Engine implementation
├── itch/              # NASDAQ ITCH 5.0 parser module
├── bench/             # High-precision benchmarking harness
├── tests/             # Unit tests using Catch2
├── scripts/           # Python & Bash utilities for data generation and plotting
└── docs/              # Technical documentation and performance analysis
```

## Getting Started

### Prerequisites

- C++20 compatible compiler (Clang 15+, GCC 11+)
- CMake 3.15+
- Python 3.8+ (for scripts)

### Build Instructions

```bash
# Configure the project
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build all targets (engine, parser, benchmark, tests)
cmake --build build
```

### Running Tests

```bash
./build/test_engine
```

## Benchmarking

The benchmarking suite replays ITCH 5.0 binary files through the engine and captures per-message latency statistics.

### 1. Generate Synthetic Data
```bash
python3 scripts/generate_itch.py --count 1000000 data/synthetic.itch
```

### 2. Run the Benchmark
On macOS (Apple Silicon), hardware counters require `sudo`:
```bash
sudo ./build/bench_engine data/synthetic.itch
```

### 3. Visualize Latency
After running the benchmark, you can plot the latency distribution:
```bash
python3 scripts/plot_latency.py latency_samples.csv
```

## Performance Engineering

The engine is designed with "Mechanical Sympathy" in mind:
- **`alignas(64)`**: Critical structures are cache-line aligned to prevent false sharing and optimize cache fetches.
- **Zero-Allocation Hot Path**: The `OrderPool` pre-allocates memory, ensuring no `new` or `delete` calls occur during order processing.
- **Minimal Branching**: Logic is structured to favor predictable execution paths.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
