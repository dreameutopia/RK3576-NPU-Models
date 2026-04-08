#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --compiler PATH     Path to cross-compiler (optional, for cross-compilation)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                              # Build on RK3576 board (native compilation)"
    echo "  $0 -c ~/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu  # Cross-compile"
    exit 1
}

COMPILER_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--compiler)
            COMPILER_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

echo "=========================================="
echo "Building Lite Transformer Demo for RK3576"
echo "=========================================="

if [ ! -f "3rdparty/librknnrt/Linux/librknn_api/aarch64/librknnrt.so" ]; then
    echo "Error: RKNN library not found!"
    echo "Please run: ./setup.sh"
    exit 1
fi

if [ ! -f "src/rknpu2/lite_transformer.cc" ]; then
    echo "Error: Source files not found!"
    echo "Please run: ./setup.sh"
    exit 1
fi

rm -rf build
mkdir -p build && cd build

if [ -n "$COMPILER_PATH" ]; then
    echo "Cross-compilation mode"
    if [ ! -d "$COMPILER_PATH" ]; then
        echo "Error: Compiler path not found: $COMPILER_PATH"
        exit 1
    fi
    cmake .. -DCMAKE_C_COMPILER=${COMPILER_PATH}/bin/aarch64-none-linux-gnu-gcc \
             -DCMAKE_CXX_COMPILER=${COMPILER_PATH}/bin/aarch64-none-linux-gnu-g++
else
    echo "Native compilation mode"
    cmake ..
fi

make -j$(nproc)
make install

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "Output: install/"
echo "=========================================="
echo ""
echo "To run:"
echo "  cd install"
echo "  export LD_LIBRARY_PATH=./lib:\$LD_LIBRARY_PATH"
echo "  ./rknn_lite_transformer_demo model/lite-transformer-encoder-16.rknn model/lite-transformer-decoder-16.rknn \"thank you\""
