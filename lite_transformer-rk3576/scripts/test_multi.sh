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

TEST_SENTENCES=(
    "thank you"
    "hello world"
    "good morning"
    "how are you"
    "nice to meet you"
)

echo "=========================================="
echo "Lite Transformer RK3576 Multi-Text Test"
echo "=========================================="
echo "Encoder Model: $ENCODER_MODEL"
echo "Decoder Model: $DECODER_MODEL"
echo "Test Sentences: ${#TEST_SENTENCES[@]}"
echo "=========================================="
echo ""

run_single_test() {
    local text=$1
    local task_id=$2
    
    echo "[Task $task_id] Input: $text"
    echo "[Task $task_id] Start Time: $(date '+%Y-%m-%d %H:%M:%S.%3N')"
    
    local start_time=$(date +%s%3N)
    
    $DEMO_PATH "$ENCODER_MODEL" "$DECODER_MODEL" "$text"
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    echo "[Task $task_id] End Time: $(date '+%Y-%m-%d %H:%M:%S.%3N')"
    echo "[Task $task_id] Duration: ${duration} ms"
    echo ""
}

echo "Starting sequential translation test for ${#TEST_SENTENCES[@]} sentences..."
echo ""

OVERALL_START=$(date +%s%3N)

for i in "${!TEST_SENTENCES[@]}"; do
    run_single_test "${TEST_SENTENCES[$i]}" "$i"
done

OVERALL_END=$(date +%s%3N)
OVERALL_DURATION=$((OVERALL_END - OVERALL_START))

echo ""
echo "=========================================="
echo "Multi-Text Test Summary"
echo "=========================================="
echo "Total Sentences: ${#TEST_SENTENCES[@]}"
echo "Overall Duration: ${OVERALL_DURATION} ms"
echo "Average Duration per Sentence: $((OVERALL_DURATION / ${#TEST_SENTENCES[@]})) ms"
echo "=========================================="
