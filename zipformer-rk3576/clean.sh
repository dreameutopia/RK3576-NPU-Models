#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Cleaning Zipformer RK3576 temporary files"
echo "=========================================="

echo "Cleaning build directory..."
rm -rf build

echo "Cleaning ONNX models..."
rm -rf onnx

echo "Cleaning install directory..."
rm -rf install

echo "=========================================="
echo "Clean completed!"
echo ""
echo "Remaining files:"
ls -la
echo "=========================================="
