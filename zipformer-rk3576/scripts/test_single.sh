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

AUDIO_PATH=""
OUTPUT_WAV=""

convert_audio() {
    local input="$1"
    local output="$2"
    
    if command -v ffmpeg &> /dev/null; then
        ffmpeg -i "$input" -ar 16000 -ac 1 -acodec pcm_s16le -y "$output" -loglevel error
        return $?
    else
        echo "Error: ffmpeg not found. Please install ffmpeg to convert audio files."
        echo "  Ubuntu/Debian: sudo apt install ffmpeg"
        echo "  CentOS/RHEL: sudo yum install ffmpeg"
        return 1
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            AUDIO_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -i, --input PATH   Input audio path (supports wav/mp3/ogg/flac)"
            echo "                     (default: model/test.wav)"
            echo "  -h, --help         Show this help"
            echo ""
            echo "Supported audio formats:"
            echo "  - WAV (16-bit PCM, recommended)"
            echo "  - MP3 (requires ffmpeg)"
            echo "  - OGG (requires ffmpeg)"
            echo "  - FLAC (requires ffmpeg)"
            echo ""
            echo "Examples:"
            echo "  $0 -i model/test.wav"
            echo "  $0 -i test/test.mp3"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$AUDIO_PATH" ]; then
    AUDIO_PATH="./model/test.wav"
fi

if [ ! -f "$AUDIO_PATH" ]; then
    echo "Error: Audio file not found: $AUDIO_PATH"
    exit 1
fi

AUDIO_EXT="${AUDIO_PATH##*.}"
AUDIO_EXT_LOWER=$(echo "$AUDIO_EXT" | tr '[:upper:]' '[:lower:]')

if [ "$AUDIO_EXT_LOWER" != "wav" ]; then
    echo "Converting $AUDIO_EXT file to WAV format (16kHz, mono, 16-bit)..."
    OUTPUT_WAV="/tmp/zipformer_input_$$.wav"
    if ! convert_audio "$AUDIO_PATH" "$OUTPUT_WAV"; then
        exit 1
    fi
    AUDIO_PATH="$OUTPUT_WAV"
    echo "Conversion completed."
    echo ""
fi

echo "=========================================="
echo "Zipformer RK3576 Single Audio Test"
echo "=========================================="
echo "Encoder Model: $ENCODER_MODEL"
echo "Decoder Model: $DECODER_MODEL"
echo "Joiner Model: $JOINER_MODEL"
echo "Audio: $AUDIO_PATH"
echo "=========================================="
echo ""

echo "Start Time: $(date '+%Y-%m-%d %H:%M:%S.%3N')"
START_TIME=$(date +%s%3N)

$DEMO_PATH "$ENCODER_MODEL" "$DECODER_MODEL" "$JOINER_MODEL" "$AUDIO_PATH"

END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "End Time: $(date '+%Y-%m-%d %H:%M:%S.%3N')"
echo "Total Duration: ${DURATION} ms"
echo "=========================================="

if [ -n "$OUTPUT_WAV" ] && [ -f "$OUTPUT_WAV" ]; then
    rm -f "$OUTPUT_WAV"
fi
