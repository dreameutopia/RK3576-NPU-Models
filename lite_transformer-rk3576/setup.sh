#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Setting up Lite Transformer RK3576 dependencies"
echo "=========================================="

RKNN_MODEL_ZOO_PATH="${RKNN_MODEL_ZOO_PATH:-../rknn_model_zoo}"

if [ ! -d "$RKNN_MODEL_ZOO_PATH" ]; then
    echo "Error: rknn_model_zoo not found at: $RKNN_MODEL_ZOO_PATH"
    echo "Please set RKNN_MODEL_ZOO_PATH environment variable"
    echo "Example: RKNN_MODEL_ZOO_PATH=/path/to/rknn_model_zoo ./setup.sh"
    exit 1
fi

echo "Using rknn_model_zoo from: $RKNN_MODEL_ZOO_PATH"

LITE_TRANSFORMER_SRC="$RKNN_MODEL_ZOO_PATH/examples/lite_transformer"

# ============================================
# Step 1: Copy RKNN runtime library
# ============================================
echo ""
echo "[1/6] Copying RKNN runtime library..."
mkdir -p 3rdparty/librknnrt/Linux/librknn_api/aarch64
mkdir -p 3rdparty/librknnrt/Linux/librknn_api/include

if [ -f "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/Linux/aarch64/librknnrt.so" ]; then
    cp "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/Linux/aarch64/librknnrt.so" 3rdparty/librknnrt/Linux/librknn_api/aarch64/
    echo "  Copied librknnrt.so"
else
    echo "  Error: librknnrt.so not found"
    exit 1
fi

if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/include" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/rknpu2/include/"* 3rdparty/librknnrt/Linux/librknn_api/include/
    echo "  Copied RKNN headers"
fi

# ============================================
# Step 2: Copy timer
# ============================================
echo ""
echo "[2/6] Copying timer..."
mkdir -p 3rdparty/timer

if [ -d "$RKNN_MODEL_ZOO_PATH/3rdparty/timer" ]; then
    cp -r "$RKNN_MODEL_ZOO_PATH/3rdparty/timer/"* 3rdparty/timer/
    echo "  Copied timer"
fi

# ============================================
# Step 3: Copy source files from rknn_model_zoo
# ============================================
echo ""
echo "[3/6] Copying source files..."

mkdir -p src/rknpu2/rkdemo_utils
mkdir -p src/utils/bpe_tools

cp "$LITE_TRANSFORMER_SRC/cpp/main.cc" src/
cp "$LITE_TRANSFORMER_SRC/cpp/lite_transformer.h" src/

cp "$LITE_TRANSFORMER_SRC/cpp/rknpu2/lite_transformer.cc" src/rknpu2/
cp "$LITE_TRANSFORMER_SRC/cpp/rknpu2/rkdemo_utils/rknn_demo_utils.cc" src/rknpu2/rkdemo_utils/
cp "$LITE_TRANSFORMER_SRC/cpp/rknpu2/rkdemo_utils/rknn_demo_utils.h" src/rknpu2/rkdemo_utils/

cp "$LITE_TRANSFORMER_SRC/cpp/utils/bpe_tools/bpe_tools.cc" src/utils/bpe_tools/
cp "$LITE_TRANSFORMER_SRC/cpp/utils/bpe_tools/bpe_tools.h" src/utils/bpe_tools/

cp "$RKNN_MODEL_ZOO_PATH/utils/file_utils.h" src/utils/
cp "$RKNN_MODEL_ZOO_PATH/utils/file_utils.c" src/utils/
cp "$RKNN_MODEL_ZOO_PATH/utils/common.h" src/utils/

echo "  Copied source files"

# ============================================
# Step 4: Copy type_half.h
# ============================================
echo ""
echo "[4/6] Copying type_half..."
mkdir -p src/utils

if [ -f "$RKNN_MODEL_ZOO_PATH/examples/lite_transformer/cpp/utils/type_half.h" ]; then
    cp "$RKNN_MODEL_ZOO_PATH/examples/lite_transformer/cpp/utils/type_half.h" src/utils/
    echo "  Copied type_half.h"
fi

# ============================================
# Step 5: Copy model files
# ============================================
echo ""
echo "[5/6] Copying model files..."
mkdir -p model

if [ -f "$LITE_TRANSFORMER_SRC/model/bpe_order.txt" ]; then
    cp "$LITE_TRANSFORMER_SRC/model/bpe_order.txt" model/
    echo "  Copied bpe_order.txt"
fi

if [ -f "$LITE_TRANSFORMER_SRC/model/dict_order.txt" ]; then
    cp "$LITE_TRANSFORMER_SRC/model/dict_order.txt" model/
    echo "  Copied dict_order.txt"
fi

if [ -f "$LITE_TRANSFORMER_SRC/model/cw_token_map_order.txt" ]; then
    cp "$LITE_TRANSFORMER_SRC/model/cw_token_map_order.txt" model/
    echo "  Copied cw_token_map_order.txt"
fi

if [ -f "$LITE_TRANSFORMER_SRC/model/position_embed.bin" ]; then
    cp "$LITE_TRANSFORMER_SRC/model/position_embed.bin" model/
    echo "  Copied position_embed.bin"
fi

if [ -f "$LITE_TRANSFORMER_SRC/model/token_embed.bin" ]; then
    cp "$LITE_TRANSFORMER_SRC/model/token_embed.bin" model/
    echo "  Copied token_embed.bin"
fi

for rknn_file in "$LITE_TRANSFORMER_SRC/model/"*.rknn; do
    if [ -f "$rknn_file" ]; then
        cp "$rknn_file" model/
        echo "  Copied $(basename $rknn_file)"
    fi
done

# ============================================
# Step 6: Create CMakeLists.txt
# ============================================
echo ""
echo "[6/6] Creating CMakeLists.txt..."

cat > CMakeLists.txt << 'CMAKEOF'
cmake_minimum_required(VERSION 3.10)

project(rknn_lite_transformer_demo)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,--allow-shlib-undefined")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wl,--allow-shlib-undefined")

if(${CMAKE_VERSION} VERSION_GREATER "3.15.0" AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  add_link_options("-Wl,-Bsymbolic")
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set (TARGET_LIB_ARCH ${CMAKE_ANDROID_ARCH_ABI})
else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set (TARGET_LIB_ARCH aarch64)
    else()
        set (TARGET_LIB_ARCH armhf)
    endif()
    if (CMAKE_C_COMPILER MATCHES "uclibc")
        set (TARGET_LIB_ARCH ${TARGET_LIB_ARCH}_uclibc)
    endif()
endif()

set(RKNN_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/librknnrt)
set(LIBRKNNRT ${RKNN_PATH}/${CMAKE_SYSTEM_NAME}/librknn_api/${TARGET_LIB_ARCH}/librknnrt.so)
set(LIBRKNNRT_INCLUDES ${RKNN_PATH}/${CMAKE_SYSTEM_NAME}/librknn_api/include)

set(LIBTIMER_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/timer)

find_package(OpenMP)

include_directories(${LIBRKNNRT_INCLUDES})
include_directories(${LIBTIMER_INCLUDES})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/utils)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/utils/bpe_tools)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/rknpu2/rkdemo_utils)

add_executable(${PROJECT_NAME}
    src/main.cc
    src/rknpu2/lite_transformer.cc
    src/rknpu2/rkdemo_utils/rknn_demo_utils.cc
    src/utils/bpe_tools/bpe_tools.cc
    src/utils/file_utils.c
)

target_link_libraries(${PROJECT_NAME}
    ${LIBRKNNRT}
    dl
)

if(OpenMP_FOUND)
    target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    target_link_libraries(${PROJECT_NAME} log)
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_libraries(${PROJECT_NAME} pthread)
endif()

set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install)
install(TARGETS ${PROJECT_NAME} DESTINATION .)
install(PROGRAMS ${LIBRKNNRT} DESTINATION lib)
install(FILES ${CMAKE_SOURCE_DIR}/run.sh DESTINATION .)
install(FILES ${CMAKE_SOURCE_DIR}/model/bpe_order.txt DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/dict_order.txt DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/cw_token_map_order.txt DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/position_embed.bin DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/token_embed.bin DESTINATION model)
file(GLOB RKNN_FILES "${CMAKE_SOURCE_DIR}/model/*.rknn")
install(FILES ${RKNN_FILES} DESTINATION model)
CMAKEOF

echo "  Created CMakeLists.txt"

# ============================================
# Summary
# ============================================
echo ""
echo "=========================================="
echo "Setup completed!"
echo "=========================================="
echo ""
echo "Copied files:"
echo ""
echo "3rdparty:"
find 3rdparty -type f 2>/dev/null | head -20
echo ""
echo "src:"
find src -type f 2>/dev/null | head -20
echo ""
echo "model:"
ls -la model/ 2>/dev/null | head -20
echo ""
echo "=========================================="
echo "Next steps:"
echo "  1. Run: ./build.sh"
echo "  2. Run: ./scripts/test_single.sh -t \"thank you\""
echo "=========================================="
