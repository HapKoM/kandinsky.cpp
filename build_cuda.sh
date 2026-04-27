#!/bin/bash

set -e # Stop execution on any error

# Define ROOT as the absolute path to the directory where the script is located
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Remove a possible trailing slash (for consistency)
ROOT=${ROOT%/}

# Build directory
BUILD_DIR="${ROOT}/build_cuda"

# Log file
LOG_FILE="${BUILD_DIR}/build_log.txt"

# --- CMake parameters ---
# Enable CUDA, set build type to RelWithDebInfo, build static library
CMAKE_ARGS="-DKD_CUDA=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF"

# If the KD_GGML_DIR environment variable is set, add the corresponding parameter
if [ -n "$KD_GGML_DIR" ]; then
    CMAKE_ARGS="$CMAKE_ARGS -DKD_GGML_DIR=$KD_GGML_DIR"
fi

# --- Create build directory (if it doesn't exist) ---
mkdir -p "$BUILD_DIR"

# --- CMake configuration ---
echo "=== CMAKE CONFIGURE ===" > "$LOG_FILE"
cmake -S "$ROOT" -B "$BUILD_DIR" -G "Unix Makefiles" $CMAKE_ARGS 2>&1 | tee -a "$LOG_FILE"

echo "=== CMAKE BUILD ===" | tee -a "$LOG_FILE"
# Run the build. The '-j$(nproc)' flag runs compilation in multiple threads for speed
cmake --build "$BUILD_DIR" --config RelWithDebInfo -- -j$(nproc) 2>&1 | tee -a "$LOG_FILE"

echo "BUILD COMPLETE" | tee -a "$LOG_FILE"
cat "$LOG_FILE"

exit 0