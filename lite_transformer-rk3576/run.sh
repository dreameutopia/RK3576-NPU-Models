#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <text_to_translate>"
    echo "Example: $0 \"thank you\""
    exit 1
fi

TEXT="$1"

export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH

./rknn_lite_transformer_demo ./model/lite-transformer-encoder-16.rknn ./model/lite-transformer-decoder-16.rknn "$TEXT"
