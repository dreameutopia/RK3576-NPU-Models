#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

DEMO_PATH=""
LIB_PATH=""

if [ -f "./install/rknn_lite_transformer_demo" ]; then
    DEMO_PATH="./install/rknn_lite_transformer_demo"
    LIB_PATH="./install/lib"
elif [ -f "./rknn_lite_transformer_demo" ]; then
    DEMO_PATH="./rknn_lite_transformer_demo"
    LIB_PATH="./lib"
else
    echo "Error: rknn_lite_transformer_demo not found!"
    echo "Please run: ./build.sh"
    exit 1
fi

export LD_LIBRARY_PATH="$LIB_PATH:$LD_LIBRARY_PATH"

ENCODER_MODEL="./model/lite-transformer-encoder-16.rknn"
DECODER_MODEL="./model/lite-transformer-decoder-16.rknn"

if [ ! -f "$ENCODER_MODEL" ]; then
    echo "Error: Encoder model not found: $ENCODER_MODEL"
    exit 1
fi

if [ ! -f "$DECODER_MODEL" ]; then
    echo "Error: Decoder model not found: $DECODER_MODEL"
    exit 1
fi

TEXT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--text)
            TEXT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -t, --text TEXT      Text to translate (default: \"thank you\")"
            echo "  -h, --help           Show this help"
            exit 0
            ;;
        *)
            TEXT="$1"
            shift
            ;;
    esac
done

if [ -z "$TEXT" ]; then
    TEXT="thank you"
fi

echo "=========================================="
echo "Lite Transformer RK3576 Translation Test"
echo "=========================================="
echo "Encoder Model: $ENCODER_MODEL"
echo "Decoder Model: $DECODER_MODEL"
echo "Input Text: $TEXT"
echo "=========================================="
echo ""

echo "Start Time: $(date '+%Y-%m-%d %H:%M:%S.%3N')"
START_TIME=$(date +%s%3N)

$DEMO_PATH "$ENCODER_MODEL" "$DECODER_MODEL" "$TEXT"

END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "End Time: $(date '+%Y-%m-%d %H:%M:%S.%3N')"
echo "Total Duration: ${DURATION} ms"
echo "=========================================="
