#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH

if [ $# -lt 4 ]; then
    echo "Usage: $0 <encoder_path> <decoder_path> <joiner_path> <audio_path>"
    echo ""
    echo "Example:"
    echo "  $0 model/encoder-epoch-99-avg-1.rknn model/decoder-epoch-99-avg-1.rknn model/joiner-epoch-99-avg-1.rknn model/test.wav"
    exit 1
fi

./zipformer_demo "$@"
