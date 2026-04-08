#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Building kaldi-native-fbank on RK3576"
echo "=========================================="

BUILD_DIR="build_kaldi"
LOCAL_TAR="kaldi-native-fbank-1.22.3.tar.gz"

mkdir -p $BUILD_DIR
cd $BUILD_DIR

if [ ! -d "kaldi-native-fbank-1.22.3" ]; then
    if [ -f "../$LOCAL_TAR" ]; then
        echo "Using local tarball: $LOCAL_TAR"
        cp "../$LOCAL_TAR" .
        tar -xzf $LOCAL_TAR
    else
        echo "Downloading kaldi-native-fbank v1.22.3..."
        wget -O v1.22.3.tar.gz "https://github.com/csukuangfj/kaldi-native-fbank/archive/refs/tags/v1.22.3.tar.gz" || {
            echo "Download failed, trying with curl..."
            curl -L -o v1.22.3.tar.gz "https://github.com/csukuangfj/kaldi-native-fbank/archive/refs/tags/v1.22.3.tar.gz"
        }
        tar -xzf v1.22.3.tar.gz
    fi
fi

cd kaldi-native-fbank-1.22.3

rm -rf build
mkdir -p build
cd build

echo "Configuring with -fPIC (no Python bindings)..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DKALDI_NATIVE_FBANK_BUILD_TESTS=OFF \
    -DKALDI_NATIVE_FBANK_BUILD_PYTHON=OFF

echo "Building..."
make -j$(nproc)

echo "Installing to 3rdparty..."
mkdir -p $SCRIPT_DIR/3rdparty/kaldi_native_fbank/include
mkdir -p $SCRIPT_DIR/3rdparty/kaldi_native_fbank/Linux/aarch64

cp -r ../kaldi-native-fbank/csrc $SCRIPT_DIR/3rdparty/kaldi_native_fbank/include/
cp lib/libkaldi-native-fbank-core.a $SCRIPT_DIR/3rdparty/kaldi_native_fbank/Linux/aarch64/

echo "=========================================="
echo "kaldi-native-fbank built successfully!"
echo ""
echo "Library location:"
ls -la $SCRIPT_DIR/3rdparty/kaldi_native_fbank/Linux/aarch64/
echo "=========================================="

cd $SCRIPT_DIR
rm -rf build
echo ""
echo "Now run: ./build.sh"
