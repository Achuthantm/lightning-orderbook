cmake_minimum_required(VERSION 3.15)
project(lightning-orderbook VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Common flags
add_compile_options(-Wall -Wextra -Wpedantic)

# --- 1. EXTERNAL DEPENDENCIES ---
include(FetchContent)

# Abseil
FetchContent_Declare(
  absl
  GIT_REPOSITORY https://github.com/abseil/abseil-cpp.git
  GIT_TAG 20240722.0
)
set(ABSL_PROPAGATE_CXX_STD ON CACHE BOOL "" FORCE)

if(APPLE AND NOT CMAKE_OSX_ARCHITECTURES)
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64" OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Build for arm64" FORCE)
  endif()
endif()

FetchContent_MakeAvailable(absl)

# Catch2
FetchContent_Declare(
  Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG v3.4.0
)
FetchContent_MakeAvailable(Catch2)

# --- 2. ENGINE CORE ---
file(GLOB_RECURSE ENGINE_CORE_SOURCES src/*.cpp)
add_library(engine_core STATIC ${ENGINE_CORE_SOURCES})
target_include_directories(engine_core PUBLIC include)
target_link_libraries(engine_core PUBLIC absl::flat_hash_map)

# --- 3. ITCH PARSER ---
file(GLOB_RECURSE ITCH_PARSER_SOURCES itch/src/*.cpp)
add_library(itch_parser STATIC ${ITCH_PARSER_SOURCES})
target_include_directories(itch_parser PUBLIC itch/include)
target_link_libraries(itch_parser PRIVATE engine_core)

# --- 4. BENCHMARKS ---
file(GLOB_RECURSE BENCH_SOURCES bench/src/*.cpp)
add_executable(bench_engine ${BENCH_SOURCES})
target_include_directories(bench_engine PRIVATE bench/include include)
target_link_libraries(bench_engine PRIVATE itch_parser engine_core)
target_compile_options(bench_engine PRIVATE -O3 -march=native -fno-exceptions -fno-rtti)

# --- 5. TESTS ---
enable_testing()

# Common test sources and support files
file(GLOB_RECURSE TEST_SOURCES tests/*.cpp)
set(TEST_SUPPORT_SOURCES bench/src/latency_stats.cpp bench/src/cycle_clock.cpp)

add_executable(test_engine ${TEST_SOURCES} ${TEST_SUPPORT_SOURCES})
target_include_directories(test_engine PRIVATE itch/include bench/include include)
target_link_libraries(test_engine PRIVATE Catch2::Catch2WithMain itch_parser engine_core)

include(Catch)
catch_discover_tests(test_engine)
