# Whisper RK3576 部署包

OpenAI Whisper 语音识别模型在 RK3576 平台的完整部署方案，实现语音转文字功能。

## 简介

Whisper 是 OpenAI 发布的通用语音识别模型，在大规模多样化音频数据集上训练，支持多语言语音识别、语音翻译和语言识别等任务。本项目将其部署到 RK3576 平台，利用 NPU 加速实现高效的语音识别功能。

### 支持的任务

- **语音识别 (ASR)**: 将语音转换为文字
- **语音翻译**: 将语音翻译成英文
- **语言识别**: 识别音频中的语言

### 支持的语言

- 英语 (en)
- 中文 (zh)
- 以及其他 90+ 种语言

## 目录结构

```
whisper-rk3576/
├── prepare_models.sh     # 模型准备脚本
├── clean.sh              # 清理临时文件
├── python/               # Python 源代码
│   ├── whisper.py        # 推理脚本
│   ├── export_onnx.py    # ONNX 导出脚本
│   └── convert_rknn.py   # RKNN 转换脚本
├── scripts/              # 测试脚本
│   ├── test_single.sh    # 单音频测试
│   ├── test_multi.sh     # 多音频测试
│   └── download_onnx.sh  # 下载预转换 ONNX 模型
├── model/                # RKNN 模型
│   ├── whisper_encoder_base.rknn
│   ├── whisper_decoder_base.rknn
│   ├── vocab_en.txt
│   ├── vocab_zh.txt
│   └── mel_80_filters.txt
├── onnx/                 # ONNX 模型 (可清理)
└── test/                 # 测试相关
    ├── audio/            # 测试音频
    └── output/           # 识别结果输出
```

## 快速开始

### 步骤 1: 安装 rknn-toolkit2 环境

```bash
# 创建虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 onnxruntime==1.16.3 soundfile numpy scipy torch
python -c "from rknn.api import RKNN; print('OK')"
```

### 步骤 2: 准备模型

#### 方法 A: 下载预转换的 ONNX 模型 (推荐)

```bash
./scripts/download_onnx.sh
```

#### 方法 B: 从源码导出 ONNX

```bash
# 安装 Whisper
pip install openai-whisper onnx-simplifier

# 导出 ONNX
python3 python/export_onnx.py --model_type base
```

### 步骤 3: 转换为 RKNN

```bash
# 激活虚拟环境
source .venv/bin/activate

# 转换 encoder
python3 python/convert_rknn.py \
    --onnx onnx/whisper_encoder_base.onnx \
    --output model/whisper_encoder_base.rknn \
    --target rk3576

# 转换 decoder
python3 python/convert_rknn.py \
    --onnx onnx/whisper_decoder_base.onnx \
    --output model/whisper_decoder_base.rknn \
    --target rk3576
```

或使用一键脚本：

```bash
./prepare_models.sh
```

### 步骤 4: 准备测试音频

```bash
# 从 rknn_model_zoo 复制测试音频
cp /workspace/rknn_model_zoo/examples/whisper/model/test_en.wav test/audio/
cp /workspace/rknn_model_zoo/examples/whisper/model/test_zh.wav test/audio/

# 或使用自己的音频文件
# 注意：音频需要是 16kHz 采样率的 WAV 格式
```

### 步骤 5: 测试

```bash
# 英文识别
./scripts/test_single.sh -a test/audio/test_en.wav -t en

# 中文识别
./scripts/test_single.sh -a test/audio/test_zh.wav -t zh

# 多音频测试
./scripts/test_multi.sh
```

## 运行参数

### whisper.py 参数

```bash
python3 python/whisper.py \
    --encoder_model model/whisper_encoder_base.rknn \
    --decoder_model model/whisper_decoder_base.rknn \
    --audio test/audio/test_en.wav \
    --task en \
    --target rk3576
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--encoder_model` | Encoder RKNN/ONNX 模型路径 | (必需) |
| `--decoder_model` | Decoder RKNN/ONNX 模型路径 | (必需) |
| `--audio` | 输入音频文件 | (必需) |
| `--task` | 识别任务 (en/zh) | en |
| `--target` | 目标平台 | rk3576 |
| `--device_id` | 设备 ID | None |

## Python API 使用

```python
from whisper import WhisperModel

# 加载模型
model = WhisperModel(
    encoder_path="model/whisper_encoder_base.rknn",
    decoder_path="model/whisper_decoder_base.rknn",
    target="rk3576"
)

# 识别音频
text = model.transcribe(
    audio_path="test/audio/test_en.wav",
    task="en"
)
print(f"识别结果: {text}")

# 释放资源
model.release()
```

## 在 RK3576 板子上运行

### 重要说明

⚠️ **开发板和 PC 使用不同的 RKNN 包：**

| 环境 | 使用包 | 用途 |
|------|--------|------|
| PC (x86) | `rknn-toolkit2` | 模型转换、仿真测试 |
| RK3576 板子 | `rknn-toolkit-lite2` | 运行推理 |

### 步骤 1: 复制文件到开发板

```bash
# 在 PC 上执行，复制必要文件到板子
scp -r model/ python/ scripts/ test/ setup_board.sh requirements-board.txt root@192.168.1.100:/www/wwwroot/RK3576-Whisper/
```

### 步骤 2: 安装 rknn-toolkit-lite2

在开发板上执行：

```bash
cd /www/wwwroot/RK3576-Whisper

# 方法 A: 使用 setup 脚本自动安装（推荐）
chmod +x setup_board.sh
./setup_board.sh

# 脚本会自动：
# 1. 创建 Python 虚拟环境 .venv
# 2. 安装依赖 (soundfile, numpy, scipy, librosa)
# 3. 下载并安装 rknn-toolkit-lite2
# 4. 创建 run.sh 便捷运行脚本
```

**如果自动安装失败，请手动安装：**

```bash
# 创建虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install -r requirements-board.txt

# 安装 rknn-toolkit-lite2 (从 rknn-toolkit2 仓库获取)
# 下载地址: https://github.com/airockchip/rknn-toolkit2/tree/master/rknn-toolkit-lite2/packages
pip install rknn_toolkit_lite2-2.0.0-cp310-cp310-linux_aarch64.whl
```

### 步骤 3: 验证安装

```bash
# 激活虚拟环境
source .venv/bin/activate

# 验证
python -c "from rknn.api import RKNN; print('RKNN OK')"
```

### 步骤 4: 运行推理

```bash
cd /www/wwwroot/RK3576-Whisper

# 激活虚拟环境
source .venv/bin/activate

# 使用默认音频测试
./scripts/test_single.sh

# 或指定音频文件
./scripts/test_single.sh -a test/audio/test_en.wav -t en

# 中文识别
./scripts/test_single.sh -a test/audio/test_zh.wav -t zh
```

### 完整部署流程

```
┌─────────────────────────────────────────────────────────────┐
│                         PC (x86)                             │
│                                                              │
│  1. python3 -m venv .venv && source .venv/bin/activate      │
│  2. pip install rknn-toolkit2                                │
│  3. 运行 prepare_models.sh 准备 RKNN 模型                    │
│  4. scp 复制文件到开发板                                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      RK3576 开发板                           │
│                                                              │
│  1. ./setup_board.sh (创建 venv + 安装依赖)                  │
│  2. source .venv/bin/activate                                │
│  3. ./scripts/test_single.sh                                 │
└─────────────────────────────────────────────────────────────┘
```

## 模型说明

### Whisper 模型变体

| 模型 | 参数量 | 相对速度 | 推荐场景 |
|------|--------|----------|----------|
| tiny | 39M | 最快 | 实时应用 |
| base | 74M | 快 | 通用场景 |
| small | 244M | 中等 | 高精度需求 |
| medium | 769M | 慢 | 专业应用 |

本项目默认使用 base 模型，在精度和速度之间取得平衡。

### 音频要求

- **采样率**: 16000 Hz (会自动重采样)
- **声道**: 单声道 (会自动转换)
- **格式**: WAV (推荐), FLAC, MP3 等
- **时长**: 最长支持 20 秒 (base 模型)

## 性能优化

### 量化

RKNN 支持 INT8 量化以获得更好的性能：

```bash
# 转换时启用量化
python3 python/convert_rknn.py \
    --onnx onnx/whisper_encoder_base.onnx \
    --output model/whisper_encoder_base_quant.rknn \
    --target rk3576 \
    --quantize
```

注意：量化可能会影响识别精度，建议测试后再部署。

## 常见问题

### Q: 开发板上报错 "No module named 'rknn'"

开发板需要安装 `rknn-toolkit-lite2`，而不是 `rknn-toolkit2`：

```bash
# 激活虚拟环境
source .venv/bin/activate

# 安装 rknn-toolkit-lite2
pip install rknn_toolkit_lite2-2.0.0-cp310-cp310-linux_aarch64.whl
```

下载地址：https://github.com/airockchip/rknn-toolkit2/tree/master/rknn-toolkit-lite2/packages

### Q: PC 上准备模型时报错 "No module named 'rknn'"

```bash
source .venv/bin/activate
pip install rknn-toolkit2
```

### Q: ONNX 导出失败

确保已正确安装 Whisper 和 onnx-simplifier：

```bash
pip install openai-whisper onnx-simplifier
```

### Q: 运行时报错 "Load RKNN model failed"

检查模型文件是否完整，以及目标平台是否正确。

### Q: 识别结果不准确

1. 确保音频质量良好，背景噪音较少
2. 确保音频采样率为 16kHz
3. 尝试使用更大的模型 (small/medium)

### Q: 支持实时语音识别吗？

当前版本支持离线音频文件识别。实时语音识别需要额外的音频流处理逻辑。

## 参考资料

- [OpenAI Whisper](https://github.com/openai/whisper)
- [RKNN-Toolkit2](https://github.com/airockchip/rknn-toolkit2)
- [RKNN Model Zoo - Whisper](https://github.com/airockchip/rknn_model_zoo/tree/main/examples/whisper)

## 许可证

Whisper 模型遵循 MIT 许可证。本项目代码遵循 MIT 许可证。
