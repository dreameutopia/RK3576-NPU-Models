#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODEL_DIR="model"
ONNX_DIR="onnx"
SRC_DIR="src"

ENCODER_ONNX_URL="https://ftrg.zbox.filez.com/v2/delivery/data/95f00b0fc900458ba134f8b180b3f7a1/examples/zipformer/encoder-epoch-99-avg-1.onnx"
DECODER_ONNX_URL="https://ftrg.zbox.filez.com/v2/delivery/data/95f00b0fc900458ba134f8b180b3f7a1/examples/zipformer/decoder-epoch-99-avg-1.onnx"
JOINER_ONNX_URL="https://ftrg.zbox.filez.com/v2/delivery/data/95f00b0fc900458ba134f8b180b3f7a1/examples/zipformer/joiner-epoch-99-avg-1.onnx"

RKNN_MODEL_ZOO_PATH="${RKNN_MODEL_ZOO_PATH:-../rknn_model_zoo}"

echo "=========================================="
echo "Zipformer RK3576 Model Preparation"
echo "=========================================="
echo ""

mkdir -p $MODEL_DIR $ONNX_DIR

download_onnx_models() {
    echo "[Step 1/3] Downloading ONNX models..."
    echo ""
    
    if [ ! -f "$ONNX_DIR/encoder-epoch-99-avg-1.onnx" ]; then
        echo "Downloading encoder-epoch-99-avg-1.onnx..."
        wget -O $ONNX_DIR/encoder-epoch-99-avg-1.onnx "$ENCODER_ONNX_URL"
    else
        echo "encoder-epoch-99-avg-1.onnx already exists, skipping..."
    fi
    
    if [ ! -f "$ONNX_DIR/decoder-epoch-99-avg-1.onnx" ]; then
        echo "Downloading decoder-epoch-99-avg-1.onnx..."
        wget -O $ONNX_DIR/decoder-epoch-99-avg-1.onnx "$DECODER_ONNX_URL"
    else
        echo "decoder-epoch-99-avg-1.onnx already exists, skipping..."
    fi
    
    if [ ! -f "$ONNX_DIR/joiner-epoch-99-avg-1.onnx" ]; then
        echo "Downloading joiner-epoch-99-avg-1.onnx..."
        wget -O $ONNX_DIR/joiner-epoch-99-avg-1.onnx "$JOINER_ONNX_URL"
    else
        echo "joiner-epoch-99-avg-1.onnx already exists, skipping..."
    fi
    
    echo ""
}

download_vocab_and_test() {
    echo "[Step 2/3] Copying vocabulary and test audio..."
    echo ""
    
    if [ ! -f "$MODEL_DIR/vocab.txt" ]; then
        if [ -f "$RKNN_MODEL_ZOO_PATH/examples/zipformer/model/vocab.txt" ]; then
            echo "Copying vocab.txt from rknn_model_zoo..."
            cp "$RKNN_MODEL_ZOO_PATH/examples/zipformer/model/vocab.txt" "$MODEL_DIR/"
        else
            echo "Error: vocab.txt not found in rknn_model_zoo"
            echo "Please ensure RKNN_MODEL_ZOO_PATH is set correctly"
            exit 1
        fi
    else
        echo "vocab.txt already exists, skipping..."
    fi
    
    if [ ! -f "$MODEL_DIR/test.wav" ]; then
        if [ -f "$RKNN_MODEL_ZOO_PATH/examples/zipformer/model/test.wav" ]; then
            echo "Copying test.wav from rknn_model_zoo..."
            cp "$RKNN_MODEL_ZOO_PATH/examples/zipformer/model/test.wav" "$MODEL_DIR/"
        else
            echo "Warning: test.wav not found in rknn_model_zoo"
        fi
    else
        echo "test.wav already exists, skipping..."
    fi
    
    echo ""
}

convert_models() {
    echo "[Step 3/3] Converting ONNX to RKNN for RK3576..."
    echo ""
    
    python3 << 'PYTHON_EOF'
from rknn.api import RKNN
import os

os.makedirs("model", exist_ok=True)

models = [
    ("encoder-epoch-99-avg-1.onnx", "encoder-epoch-99-avg-1.rknn"),
    ("decoder-epoch-99-avg-1.onnx", "decoder-epoch-99-avg-1.rknn"),
    ("joiner-epoch-99-avg-1.onnx", "joiner-epoch-99-avg-1.rknn"),
]

for onnx_name, rknn_name in models:
    onnx_path = f"onnx/{onnx_name}"
    rknn_path = f"model/{rknn_name}"
    
    if os.path.exists(rknn_path):
        print(f"{rknn_name} already exists, skipping...")
        continue
    
    print(f"Converting {onnx_name}...")
    rknn = RKNN(verbose=False)
    rknn.config(target_platform='rk3576')
    
    ret = rknn.load_onnx(model=onnx_path)
    if ret != 0:
        print(f'Load {onnx_name} failed!')
        exit(1)
    
    ret = rknn.build(do_quantization=False)
    if ret != 0:
        print(f'Build {onnx_name} failed!')
        exit(1)
    
    ret = rknn.export_rknn(rknn_path)
    if ret != 0:
        print(f'Export {rknn_name} failed!')
        exit(1)
    
    rknn.release()
    print(f'{rknn_name} saved!')

print('\nAll models converted successfully!')
PYTHON_EOF
    
    echo ""
}

check_models() {
    echo "Checking model files..."
    echo ""
    
    local all_ready=true
    
    if [ -f "$MODEL_DIR/encoder-epoch-99-avg-1.rknn" ]; then
        echo "✓ Encoder model: $MODEL_DIR/encoder-epoch-99-avg-1.rknn"
    else
        echo "✗ Encoder model not found"
        all_ready=false
    fi
    
    if [ -f "$MODEL_DIR/decoder-epoch-99-avg-1.rknn" ]; then
        echo "✓ Decoder model: $MODEL_DIR/decoder-epoch-99-avg-1.rknn"
    else
        echo "✗ Decoder model not found"
        all_ready=false
    fi
    
    if [ -f "$MODEL_DIR/joiner-epoch-99-avg-1.rknn" ]; then
        echo "✓ Joiner model: $MODEL_DIR/joiner-epoch-99-avg-1.rknn"
    else
        echo "✗ Joiner model not found"
        all_ready=false
    fi
    
    if [ -f "$MODEL_DIR/vocab.txt" ]; then
        echo "✓ Vocabulary: $MODEL_DIR/vocab.txt"
    else
        echo "✗ Vocabulary not found"
        all_ready=false
    fi
    
    if [ -f "$MODEL_DIR/test.wav" ]; then
        echo "✓ Test audio: $MODEL_DIR/test.wav"
    else
        echo "✗ Test audio not found"
        all_ready=false
    fi
    
    echo ""
    
    if [ "$all_ready" = true ]; then
        echo "=========================================="
        echo "All models are ready!"
        echo "=========================================="
        echo ""
        echo "Next steps:"
        echo "  1. Run: ./setup.sh"
        echo "  2. Run: ./build.sh"
        echo "  3. Run: ./scripts/test_single.sh -i model/test.wav"
    else
        echo "=========================================="
        echo "Some files are missing."
        echo "Please ensure rknn-toolkit2 is installed correctly."
        echo "=========================================="
        exit 1
    fi
}

main() {
    download_onnx_models
    download_vocab_and_test
    convert_models
    check_models
}

main "$@"
