#!/bin/bash
set -e

echo "=========================================="
echo "Whisper RK3576 Board Setup"
echo "=========================================="
echo ""
echo "This script sets up the environment on RK3576 board."
echo ""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/.venv"

create_venv() {
    echo "[Step 1/4] Creating Python virtual environment..."
    echo ""
    
    if [ -d "$VENV_DIR" ]; then
        echo "Virtual environment already exists at $VENV_DIR"
        read -p "Remove and recreate? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
        else
            echo "Using existing virtual environment."
            source "$VENV_DIR/bin/activate"
            return
        fi
    fi
    
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    
    echo "Virtual environment created at $VENV_DIR"
    echo ""
}

install_dependencies() {
    echo "[Step 2/4] Installing Python dependencies..."
    echo ""
    
    pip install --upgrade pip
    
    pip install -r requirements-board.txt
    
    echo "Dependencies installed."
    echo ""
}

check_rknn_lite() {
    echo "[Step 3/4] Checking RKNN Toolkit Lite2..."
    echo ""
    
    if python -c "from rknn.api import RKNN" 2>/dev/null; then
        echo "RKNN Toolkit Lite2 is already installed."
    else
        echo "RKNN Toolkit Lite2 is NOT installed."
        echo ""
        echo "=========================================="
        echo "请手动安装 rknn-toolkit-lite2"
        echo "=========================================="
        echo ""
        echo "方法 1: 从本地 whl 文件安装"
        echo "  pip install rknn_toolkit_lite2-*.whl"
        echo ""
        echo "方法 2: 从 GitHub Releases 下载"
        echo "  访问: https://github.com/airockchip/rknn-toolkit2/tree/master/rknn-toolkit-lite2/packages"
        echo "  下载对应 Python 版本的 whl 文件后安装"
        echo ""
        echo "方法 3: 如果有 rknn-llm 目录"
        echo "  pip install /path/to/rknn-llm/rkllm-toolkit/packages/rkllm_toolkit-*.whl"
        echo ""
        echo "安装完成后，重新运行此脚本验证。"
        echo ""
        exit 1
    fi
    echo ""
}

verify_installation() {
    echo "[Step 4/4] Verifying installation..."
    echo ""
    
    echo "Checking Python packages..."
    python -c "import numpy; print(f'  numpy: {numpy.__version__}')"
    python -c "import scipy; print(f'  scipy: {scipy.__version__}')"
    python -c "import soundfile; print('  soundfile: OK')"
    python -c "from rknn.api import RKNN; print('  rknn: OK')"
    
    echo ""
    echo "=========================================="
    echo "Setup completed successfully!"
    echo "=========================================="
    echo ""
    echo "Virtual environment: $VENV_DIR"
    echo ""
    echo "Usage:"
    echo "  source .venv/bin/activate"
    echo "  ./scripts/test_single.sh -a test/audio/test_en.wav -t en"
    echo ""
}

main() {
    create_venv
    install_dependencies
    check_rknn_lite
    verify_installation
}

main "$@"
