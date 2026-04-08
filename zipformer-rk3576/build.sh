#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Building Zipformer Demo for RK3576"
echo "=========================================="

if [ ! -d "3rdparty/rknpu2" ]; then
    echo "Error: 3rdparty not found!"
    echo "Please run: ./setup.sh <path_to_rknn_model_zoo>"
    exit 1
fi

rm -rf build
mkdir -p build && cd build

echo "Native compilation mode"
cmake ..

make -j$(nproc)
make install

echo "=========================================="
echo "Build completed successfully!"
echo "Output: install/"
echo ""
echo "Run: cd install && ./run.sh ../model/encoder-epoch-99-avg-1.rknn ../model/decoder-epoch-99-avg-1.rknn ../model/joiner-epoch-99-avg-1.rknn ../model/test.wav"
echo "=========================================="
