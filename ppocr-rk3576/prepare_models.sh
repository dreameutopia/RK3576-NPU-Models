#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODEL_DIR="model"
ONNX_DIR="onnx"
SRC_DIR="src"

DET_ONNX_URL="https://ftrg.zbox.filez.com/v2/delivery/data/95f00b0fc900458ba134f8b180b3f7a1/examples/PPOCR/ppocrv4_det.onnx"
REC_ONNX_URL="https://ftrg.zbox.filez.com/v2/delivery/data/95f00b0fc900458ba134f8b180b3f7a1/examples/PPOCR/ppocrv4_rec.onnx"

echo "=========================================="
echo "PPOCR RK3576 Model Preparation"
echo "=========================================="
echo ""

mkdir -p $MODEL_DIR $ONNX_DIR

download_dict() {
    echo "[Step 1/3] Preparing character dictionary..."
    echo ""
    
    DICT_TXT="$ONNX_DIR/ppocr_keys_v1.txt"
    DICT_HEADER="$SRC_DIR/dict.h"
    
    if [ -f "$DICT_HEADER" ]; then
        echo "dict.h already exists, skipping..."
        return 0
    fi
    
    if [ ! -f "$DICT_TXT" ]; then
        echo "Copying from local rknn_model_zoo..."
        if [ -f "/workspace/rknn_model_zoo/examples/PPOCR/PPOCR-System/model/ppocr_keys_v1.txt" ]; then
            cp /workspace/rknn_model_zoo/examples/PPOCR/PPOCR-System/model/ppocr_keys_v1.txt "$DICT_TXT"
        else
            echo "Error: Dictionary file not found"
            exit 1
        fi
    fi
    
    python3 -c "
import sys

dict_file = '$DICT_TXT'
header_file = '$DICT_HEADER'

with open(dict_file, 'r', encoding='utf-8') as f:
    chars = [line.strip() for line in f if line.strip()]

chars.insert(0, 'blank')

with open(header_file, 'w', encoding='utf-8') as f:
    f.write('#include <string>\n\n')
    f.write(f'const std::string ocr_dict[{len(chars)}] = {{')
    
    for i, char in enumerate(chars):
        if i % 20 == 0:
            f.write('\n    ')
        escaped = char.replace('\\\\', '\\\\\\\\').replace('\"', '\\\\\"')
        f.write(f'\"{escaped}\", ')
    
    f.write('\n};\n')

print(f'Generated dict.h with {len(chars)} characters')
"
    
    echo "dict.h generated successfully."
    echo ""
}

download_onnx_models() {
    echo "[Step 2/3] Downloading ONNX models..."
    echo ""
    
    if [ ! -f "$ONNX_DIR/ppocrv4_det.onnx" ]; then
        echo "Downloading ppocrv4_det.onnx..."
        wget -O $ONNX_DIR/ppocrv4_det.onnx "$DET_ONNX_URL"
    else
        echo "ppocrv4_det.onnx already exists, skipping..."
    fi
    
    if [ ! -f "$ONNX_DIR/ppocrv4_rec.onnx" ]; then
        echo "Downloading ppocrv4_rec.onnx..."
        wget -O $ONNX_DIR/ppocrv4_rec.onnx "$REC_ONNX_URL"
    else
        echo "ppocrv4_rec.onnx already exists, skipping..."
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

print("Converting detection model...")
rknn = RKNN(verbose=False)
rknn.config(
    mean_values=[[123.675, 116.28, 103.53]], 
    std_values=[[58.395, 57.12, 57.375]], 
    target_platform='rk3576'
)
ret = rknn.load_onnx(model='onnx/ppocrv4_det.onnx')
if ret != 0:
    print('Load detection model failed!')
    exit(1)
ret = rknn.build(do_quantization=False)
if ret != 0:
    print('Build detection model failed!')
    exit(1)
ret = rknn.export_rknn('model/ppocrv4_det_serverial.rknn')
rknn.release()
print('Detection model saved!')

print("\nConverting recognition model...")
rknn = RKNN(verbose=False)
rknn.config(target_platform='rk3576')
ret = rknn.load_onnx(model='onnx/ppocrv4_rec.onnx')
if ret != 0:
    print('Load recognition model failed!')
    exit(1)
ret = rknn.build(do_quantization=False)
if ret != 0:
    print('Build recognition model failed!')
    exit(1)
ret = rknn.export_rknn('model/ppocrv4_rec_serverial.rknn')
rknn.release()
print('Recognition model saved!')
PYTHON_EOF
    
    echo ""
}

check_models() {
    echo "Checking model files..."
    echo ""
    
    local all_ready=true
    
    if [ -f "$MODEL_DIR/ppocrv4_det_serverial.rknn" ]; then
        echo "✓ Detection model: $MODEL_DIR/ppocrv4_det_serverial.rknn"
    else
        echo "✗ Detection model not found"
        all_ready=false
    fi
    
    if [ -f "$MODEL_DIR/ppocrv4_rec_serverial.rknn" ]; then
        echo "✓ Recognition model: $MODEL_DIR/ppocrv4_rec_serverial.rknn"
    else
        echo "✗ Recognition model not found"
        all_ready=false
    fi
    
    if [ -f "$SRC_DIR/dict.h" ]; then
        echo "✓ Character dictionary: $SRC_DIR/dict.h"
    else
        echo "✗ Character dictionary not found"
        all_ready=false
    fi
    
    echo ""
    
    if [ "$all_ready" = true ]; then
        echo "=========================================="
        echo "All models are ready!"
        echo "=========================================="
        echo ""
        echo "Next steps:"
        echo "  1. Run: ./build.sh"
        echo "  2. Run: ./scripts/test_single.sh -i test/test1.png"
    else
        echo "=========================================="
        echo "Some files are missing."
        echo "Please ensure rknn-toolkit2 is installed correctly."
        echo "=========================================="
        exit 1
    fi
}

main() {
    download_dict
    download_onnx_models
    convert_models
    check_models
}

main "$@"
