#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

DEMO_PATH=""
LIB_PATH=""

if [ -f "./install/zipformer_demo" ]; then
    DEMO_PATH="./install/zipformer_demo"
    LIB_PATH="./install/lib"
elif [ -f "./zipformer_demo" ]; then
    DEMO_PATH="./zipformer_demo"
    LIB_PATH="./lib"
else
    echo "Error: zipformer_demo not found!"
    echo "Please run: ./build.sh"
    exit 1
fi

export LD_LIBRARY_PATH="$LIB_PATH:$LD_LIBRARY_PATH"

ENCODER_MODEL="./model/encoder-epoch-99-avg-1.rknn"
DECODER_MODEL="./model/decoder-epoch-99-avg-1.rknn"
JOINER_MODEL="./model/joiner-epoch-99-avg-1.rknn"

if [ ! -f "$ENCODER_MODEL" ]; then
    echo "Error: Encoder model not found: $ENCODER_MODEL"
    exit 1
fi

if [ ! -f "$DECODER_MODEL" ]; then
    echo "Error: Decoder model not found: $DECODER_MODEL"
    exit 1
fi

if [ ! -f "$JOINER_MODEL" ]; then
    echo "Error: Joiner model not found: $JOINER_MODEL"
    exit 1
fi

convert_audio() {
    local input="$1"
    local output="$2"
    
    if command -v ffmpeg &> /dev/null; then
        ffmpeg -i "$input" -ar 16000 -ac 1 -acodec pcm_s16le -y "$output" -loglevel error
        return $?
    else
        echo "Error: ffmpeg not found for audio conversion"
        return 1
    fi
}

run_inference() {
    local audio_file="$1"
    local instance_id="$2"
    local output_file="/tmp/zipformer_result_${instance_id}.txt"
    
    local audio_ext="${audio_file##*.}"
    local audio_ext_lower=$(echo "$audio_ext" | tr '[:upper:]' '[:lower:]')
    local wav_file="$audio_file"
    
    if [ "$audio_ext_lower" != "wav" ]; then
        wav_file="/tmp/zipformer_input_${instance_id}.wav"
        if ! convert_audio "$audio_file" "$wav_file"; then
            echo "[Instance $instance_id] Failed to convert audio"
            return 1
        fi
    fi
    
    echo "[Instance $instance_id] Processing: $audio_file"
    
    local start_time=$(date +%s%3N)
    
    $DEMO_PATH "$ENCODER_MODEL" "$DECODER_MODEL" "$JOINER_MODEL" "$wav_file" > "$output_file" 2>&1
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    local result=$(grep "Recognized text:" "$output_file" | sed 's/Recognized text: //')
    local rtf=$(grep "Real Time Factor" "$output_file" | tail -1)
    
    echo "[Instance $instance_id] Result: $result"
    echo "[Instance $instance_id] $rtf"
    echo "[Instance $instance_id] Duration: ${duration} ms"
    
    if [ "$audio_ext_lower" != "wav" ] && [ -f "$wav_file" ]; then
        rm -f "$wav_file"
    fi
    rm -f "$output_file"
    
    echo "$duration"
}

run_concurrent_test() {
    local num_instances="$1"
    shift
    local audio_files=("$@")
    
    echo "=========================================="
    echo "Concurrent Inference Test ($num_instances instances)"
    echo "=========================================="
    echo ""
    
    local pids=()
    local start_time=$(date +%s%3N)
    
    for ((i=0; i<num_instances; i++)); do
        local audio_idx=$((i % ${#audio_files[@]}))
        local audio_file="${audio_files[$audio_idx]}"
        
        (
            run_inference "$audio_file" $((i+1))
        ) &
        pids+=($!)
    done
    
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    local end_time=$(date +%s%3N)
    local total_duration=$((end_time - start_time))
    
    echo ""
    echo "=========================================="
    echo "Concurrent Test Summary"
    echo "=========================================="
    echo "Instances: $num_instances"
    echo "Total Wall Time: ${total_duration} ms"
    echo "Average per instance: $((total_duration / num_instances)) ms"
    echo "=========================================="
}

run_sequential_test() {
    local audio_files=("$@")
    
    echo "=========================================="
    echo "Sequential Multi-Audio Test"
    echo "=========================================="
    echo ""
    
    local total_files=0
    local total_time=0
    
    for audio_file in "${audio_files[@]}"; do
        if [ ! -f "$audio_file" ]; then
            echo "Skipping: $audio_file (not found)"
            continue
        fi
        
        total_files=$((total_files + 1))
        
        echo "----------------------------------------"
        echo "[$total_files] Testing: $audio_file"
        echo "----------------------------------------"
        
        local audio_ext="${audio_file##*.}"
        local audio_ext_lower=$(echo "$audio_ext" | tr '[:upper:]' '[:lower:]')
        local wav_file="$audio_file"
        
        if [ "$audio_ext_lower" != "wav" ]; then
            wav_file="/tmp/zipformer_input_${total_files}.wav"
            if ! convert_audio "$audio_file" "$wav_file"; then
                continue
            fi
        fi
        
        local start_time=$(date +%s%3N)
        
        $DEMO_PATH "$ENCODER_MODEL" "$DECODER_MODEL" "$JOINER_MODEL" "$wav_file"
        
        local end_time=$(date +%s%3N)
        local duration=$((end_time - start_time))
        total_time=$((total_time + duration))
        
        if [ "$audio_ext_lower" != "wav" ] && [ -f "$wav_file" ]; then
            rm -f "$wav_file"
        fi
        
        echo ""
        echo "Duration: ${duration} ms"
        echo ""
    done
    
    echo "=========================================="
    echo "Summary"
    echo "=========================================="
    echo "Total files tested: $total_files"
    echo "Total time: ${total_time} ms"
    if [ $total_files -gt 0 ]; then
        echo "Average time: $((total_time / total_files)) ms"
    fi
    echo "=========================================="
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -m, --mode MODE      Test mode: sequential or concurrent (default: sequential)"
    echo "  -n, --num NUM        Number of concurrent instances (default: 2)"
    echo "  -d, --dir DIR        Directory containing audio files (default: test/)"
    echo "  -h, --help           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                              # Sequential test on test/ directory"
    echo "  $0 -m concurrent -n 4           # Concurrent test with 4 instances"
    echo "  $0 -d /path/to/audio            # Test specific directory"
    echo "  $0 -m concurrent -n 2 -d test/  # Concurrent test on test/ directory"
    exit 0
}

MODE="sequential"
NUM_INSTANCES=2
AUDIO_DIR="./test"

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -n|--num)
            NUM_INSTANCES="$2"
            shift 2
            ;;
        -d|--dir)
            AUDIO_DIR="$2"
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

if [ ! -d "$AUDIO_DIR" ]; then
    echo "Warning: $AUDIO_DIR not found, using model/test.wav"
    AUDIO_DIR="./model"
fi

AUDIO_FILES=()
while IFS= read -r -d '' file; do
    AUDIO_FILES+=("$file")
done < <(find "$AUDIO_DIR" -type f \( -name "*.wav" -o -name "*.mp3" -o -name "*.ogg" -o -name "*.flac" \) -print0 2>/dev/null)

if [ ${#AUDIO_FILES[@]} -eq 0 ]; then
    echo "No audio files found in $AUDIO_DIR"
    echo "Supported formats: wav, mp3, ogg, flac"
    echo ""
    echo "Please add test audio files to test/ directory:"
    echo "  - test/test1.wav"
    echo "  - test/test2.mp3"
    echo "  - test/test3.wav"
    echo "  ..."
    exit 1
fi

echo "Found ${#AUDIO_FILES[@]} audio file(s) in $AUDIO_DIR"
echo "Files: ${AUDIO_FILES[*]}"
echo ""

case "$MODE" in
    concurrent)
        run_concurrent_test "$NUM_INSTANCES" "${AUDIO_FILES[@]}"
        ;;
    sequential|*)
        run_sequential_test "${AUDIO_FILES[@]}"
        ;;
esac
