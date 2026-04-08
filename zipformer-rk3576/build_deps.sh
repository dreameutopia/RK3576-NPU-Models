#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Building all dependencies on RK3576"
echo "=========================================="

BUILD_DIR="build_deps"
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# 1. Build kissfft first
echo ""
echo "[1/3] Building kissfft..."
KISSFFT_ZIP="kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec.zip"
if [ ! -d "kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec" ]; then
    if [ -f "../$KISSFFT_ZIP" ]; then
        echo "Using local kissfft zip..."
        cp "../$KISSFFT_ZIP" .
        unzip -o $KISSFFT_ZIP
    else
        echo "Downloading kissfft..."
        wget -O $KISSFFT_ZIP "https://github.com/mborgerding/kissfft/archive/febd4caeed32e33ad8b2e0bb5ea77542c40f18ec.zip"
        unzip -o $KISSFFT_ZIP
    fi
fi

cd kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec
rm -rf build
mkdir -p build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DKISSFFT_BUILD_TESTS=OFF \
    -DKISSFFT_BUILD_TOOLS=OFF \
    -DKISSFFT_FLOAT=ON \
    -DKISSFFT_INT=OFF \
    -DKISSFFT_DOUBLE=OFF

make -j$(nproc)

KISSFFT_LIB="$(pwd)/libkissfft-float.a"
echo "kissfft library: $KISSFFT_LIB"

cd ..

# 2. Build kaldi-native-fbank
echo ""
echo "[2/3] Building kaldi-native-fbank..."
cd ..

if [ ! -d "kaldi-native-fbank-1.22.3" ]; then
    if [ -f "../kaldi-native-fbank-1.22.3.tar.gz" ]; then
        echo "Using local tarball..."
        cp "../kaldi-native-fbank-1.22.3.tar.gz" .
        tar -xzf kaldi-native-fbank-1.22.3.tar.gz
    else
        wget -O kaldi-native-fbank-1.22.3.tar.gz "https://github.com/csukuangfj/kaldi-native-fbank/archive/refs/tags/v1.22.3.tar.gz"
        tar -xzf kaldi-native-fbank-1.22.3.tar.gz
    fi
fi

cd kaldi-native-fbank-1.22.3
rm -rf build
mkdir -p build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DKALDI_NATIVE_FBANK_BUILD_TESTS=OFF \
    -DKALDI_NATIVE_FBANK_BUILD_PYTHON=OFF \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DFETCHCONTENT_SOURCE_DIR_KISSFFT=../../kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec

make -j$(nproc)

cd ..

# 3. Build libsndfile
echo ""
echo "[3/3] Building libsndfile..."
cd ..

if [ ! -d "libsndfile-1.2.2" ]; then
    if [ -f "../libsndfile-1.2.2.tar.xz" ]; then
        echo "Using local tarball..."
        cp "../libsndfile-1.2.2.tar.xz" .
        tar -xJf libsndfile-1.2.2.tar.xz
    elif [ -f "../libsndfile-1.2.2.tar.gz" ]; then
        cp "../libsndfile-1.2.2.tar.gz" .
        tar -xzf libsndfile-1.2.2.tar.gz
    else
        wget -O libsndfile-1.2.2.tar.xz "https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz"
        tar -xJf libsndfile-1.2.2.tar.xz
    fi
fi

cd libsndfile-1.2.2
rm -rf build
mkdir -p build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_PROGRAMS=OFF \
    -DENABLE_EXTERNAL_LIBS=OFF \
    -DENABLE_MPEG=OFF

make -j$(nproc)

cd ..

# Find the actual library file
SNDFILE_LIB=$(find build -name "*.a" -type f | grep -E "(sndfile|SndFile)" | head -1)
if [ -z "$SNDFILE_LIB" ]; then
    SNDFILE_LIB=$(find build -name "*.a" -type f | head -1)
fi
echo "Found libsndfile: $SNDFILE_LIB"

# Install all libraries
echo ""
echo "=========================================="
echo "Installing libraries to 3rdparty..."
echo "=========================================="

# kissfft
mkdir -p $SCRIPT_DIR/3rdparty/kissfft/include
mkdir -p $SCRIPT_DIR/3rdparty/kissfft/Linux/aarch64
cp -r ../kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec/*.h $SCRIPT_DIR/3rdparty/kissfft/include/ 2>/dev/null || true
cp -r ../kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec/build/*.h $SCRIPT_DIR/3rdparty/kissfft/include/ 2>/dev/null || true
cp ../kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec/build/libkissfft-float.a $SCRIPT_DIR/3rdparty/kissfft/Linux/aarch64/

# kaldi-native-fbank
mkdir -p $SCRIPT_DIR/3rdparty/kaldi_native_fbank/include
mkdir -p $SCRIPT_DIR/3rdparty/kaldi_native_fbank/Linux/aarch64
cp -r ../kaldi-native-fbank-1.22.3/kaldi-native-fbank/csrc $SCRIPT_DIR/3rdparty/kaldi_native_fbank/include/
cp ../kaldi-native-fbank-1.22.3/build/lib/libkaldi-native-fbank-core.a $SCRIPT_DIR/3rdparty/kaldi_native_fbank/Linux/aarch64/

# libsndfile
mkdir -p $SCRIPT_DIR/3rdparty/libsndfile/include
mkdir -p $SCRIPT_DIR/3rdparty/libsndfile/Linux/aarch64
cp -r ../libsndfile-1.2.2/include/* $SCRIPT_DIR/3rdparty/libsndfile/include/
cp "$SNDFILE_LIB" $SCRIPT_DIR/3rdparty/libsndfile/Linux/aarch64/libsndfile.a

echo ""
echo "=========================================="
echo "All dependencies built successfully!"
echo ""
echo "kissfft:"
ls -la $SCRIPT_DIR/3rdparty/kissfft/Linux/aarch64/
echo ""
echo "kaldi-native-fbank:"
ls -la $SCRIPT_DIR/3rdparty/kaldi_native_fbank/Linux/aarch64/
echo ""
echo "libsndfile:"
ls -la $SCRIPT_DIR/3rdparty/libsndfile/Linux/aarch64/
echo "=========================================="

cd $SCRIPT_DIR
rm -rf build
echo ""
echo "Now run: ./build.sh"
