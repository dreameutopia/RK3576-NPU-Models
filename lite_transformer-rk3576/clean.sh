#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Cleaning Lite Transformer RK3576"
echo "=========================================="

rm -rf build
rm -rf install
rm -rf onnx

echo "Clean completed!"
echo ""
echo "Note: Model files in 'model/' directory are preserved."
echo "To remove model files, run: rm -rf model"
