#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Setting up Zipformer RK3576 dependencies"
echo "=========================================="

RKNN_MODEL_ZOO_PATH="${1:-../rknn_model_zoo}"

if [ ! -d "$RKNN_MODEL_ZOO_PATH" ]; then
    echo "Error: rknn_model_zoo not found at: $RKNN_MODEL_ZOO_PATH"
    echo ""
    echo "Usage: $0 <path_to_rknn_model_zoo>"
    echo ""
    echo "Example:"
    echo "  $0 /path/to/rknn_model_zoo"
    echo "  $0 ../rknn_model_zoo"
    exit 1
fi

echo "Using rknn_model_zoo from: $RKNN_MODEL_ZOO_PATH"
echo ""

echo "[1/6] Creating directory structure..."
mkdir -p 3rdparty/rknpu2/Linux/aarch64
mkdir -p 3rdparty/rknpu2/include
mkdir -p 3rdparty/kaldi_native_fbank/Linux/aarch64
mkdir -p 3rdparty/kaldi_native_fbank/include
mkdir -p 3rdparty/timer
mkdir -p 3rdparty/fftw/Linux/aarch64
mkdir -p 3rdparty/fftw/include
mkdir -p 3rdparty/libsndfile/Linux/aarch64
mkdir -p 3rdparty/libsndfile/include
mkdir -p 3rdparty/stb_image
mkdir -p utils

echo "[2/6] Copying RKNN runtime..."
if [ -f "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/Linux/aarch64/librknnrt.so" ]; then
    cp "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/Linux/aarch64/librknnrt.so" 3rdparty/rknpu2/Linux/aarch64/
    echo "  Copied librknnrt.so"
else
    echo "  Error: librknnrt.so not found"
    exit 1
fi

if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/include" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/include/"* 3rdparty/rknpu2/include/
    echo "  Copied RKNN headers"
fi

echo "[3/6] Copying kaldi-native-fbank..."
if [ -f "$RKNN_MODEL_ZOO_PATH/3rdparty/kaldi_native_fbank/Linux/aarch64/libkaldi-native-fbank-core.a" ]; then
    cp "$RKNN_MODEL_ZOO_PATH/3rdparty/kaldi_native_fbank/Linux/aarch64/libkaldi-native-fbank-core.a" 3rdparty/kaldi_native_fbank/Linux/aarch64/
    echo "  Copied libkaldi-native-fbank-core.a"
else
    echo "  Error: libkaldi-native-fbank-core.a not found"
    exit 1
fi

if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/kaldi_native_fbank/include" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/kaldi_native_fbank/include/"* 3rdparty/kaldi_native_fbank/include/
    echo "  Copied kaldi-native-fbank headers"
fi

echo "[4/6] Copying timer..."
if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/timer" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/timer/"* 3rdparty/timer/
    echo "  Copied timer"
fi

echo "[5/6] Copying fftw and libsndfile..."
if [ -f "$RKNN_MODEL_ZOO_PATH/3rdparty/fftw/Linux/aarch64/libfftw3f.a" ]; then
    cp "$RKNN_MODEL_ZOO_PATH/3rdparty/fftw/Linux/aarch64/libfftw3f.a" 3rdparty/fftw/Linux/aarch64/
    echo "  Copied libfftw3f.a"
fi
if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/fftw/include" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/fftw/include/"* 3rdparty/fftw/include/
fi

if [ -f "$RKNN_MODEL_ZOO_PATH/3rdparty/libsndfile/Linux/aarch64/libsndfile.a" ]; then
    cp "$RKNN_MODEL_ZOO_PATH/3rdparty/libsndfile/Linux/aarch64/libsndfile.a" 3rdparty/libsndfile/Linux/aarch64/
    echo "  Copied libsndfile.a"
fi
if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/libsndfile/include" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/libsndfile/include/"* 3rdparty/libsndfile/include/
fi

echo "[6/6] Copying utils..."
if [ -d "$RKNN_MODEL_ZOO_PATH/utils" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/utils/"* utils/
    echo "  Copied utils"
fi

if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/stb_image" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/stb_image/"* 3rdparty/stb_image/
fi

echo ""
echo "=========================================="
echo "Setup completed!"
echo ""
echo "3rdparty files:"
find 3rdparty -type f 2>/dev/null | head -20
echo ""
echo "Next steps:"
echo "  1. Copy this folder to RK3576 board"
echo "  2. Run: ./build.sh"
echo "  3. Run: ./scripts/test_single.sh -i model/test.wav"
echo "=========================================="
