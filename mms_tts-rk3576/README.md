# MMS-TTS RK3576 部署包

Facebook MMS-TTS (Massively Multilingual Speech) 在 RK3576 平台的完整部署方案，实现文字转语音功能。

## 简介

MMS-TTS 是 Facebook 发布的大规模多语言语音合成模型，支持超过 1000 种语言。本项目基于 [rknn_model_zoo/examples/mms_tts](https://github.com/airockchip/rknn_model_zoo/tree/main/examples/mms_tts) 实现，将模型拆分为 encoder 和 decoder 两部分，使其能够在 RKNN NPU 上运行。

### 支持的语言

| 语言代码 | 语言 | HuggingFace 模型 |
|---------|------|-----------------|
| eng | 英语 | facebook/mms-tts-eng |
| zho | 中文 | facebook/mms-tts-zho |
| deu | 德语 | facebook/mms-tts-deu |
| fra | 法语 | facebook/mms-tts-fra |
| spa | 西班牙语 | facebook/mms-tts-spa |
| jpn | 日语 | facebook/mms-tts-jpn |
| kor | 韩语 | facebook/mms-tts-kor |

## 目录结构

```
mms_tts-rk3576/
├── prepare_models.sh     # PC 端模型准备脚本
├── setup_board.sh        # 开发板环境安装脚本
├── clean.sh              # 清理临时文件
├── run.sh                # 便捷运行脚本
├── python/               # Python 源代码
│   ├── export_onnx.py    # ONNX 导出脚本
│   ├── convert_rknn.py   # RKNN 转换脚本
│   └── mms_tts.py        # 推理脚本
├── scripts/              # 测试脚本
│   ├── test_single.sh    # 单文本测试
│   ├── test_multi.sh     # 多文本测试
│   └── download_onnx.sh  # 下载预转换 ONNX 模型
├── model/                # RKNN 模型
│   ├── mms_tts_eng_encoder_200.rknn
│   └── mms_tts_eng_decoder_200.rknn
├── onnx/                 # ONNX 模型 (可清理)
└── test/                 # 测试相关
    ├── test_texts.txt    # 测试文本
    └── output/           # 音频输出
```

## 快速开始

### 步骤 1: 安装 rknn-toolkit2 环境 (PC 端)

```bash
# 创建虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 onnxruntime==1.16.3 soundfile numpy torch
python -c "from rknn.api import RKNN; print('OK')"
```

### 步骤 2: 准备模型

#### 方法 A: 下载预转换的 ONNX 模型 (推荐)

```bash
./scripts/download_onnx.sh
```

#### 方法 B: 从源码导出 ONNX

```bash
# 安装依赖
pip install transformers torch

# 导出英文模型
python3 python/export_onnx.py --language eng --max_length 200
```

### 步骤 3: 转换为 RKNN

```bash
source .venv/bin/activate

python3 python/convert_rknn.py \
    --encoder onnx/mms_tts_eng_encoder_200.onnx \
    --decoder onnx/mms_tts_eng_decoder_200.onnx \
    --target rk3576
```

或使用一键脚本：

```bash
./prepare_models.sh
```

### 步骤 4: 测试

```bash
./scripts/test_single.sh -t "Hello, this is a test."
```

## 运行参数

### mms_tts.py 参数

```bash
python3 python/mms_tts.py \
    --encoder model/mms_tts_eng_encoder_200.rknn \
    --decoder model/mms_tts_eng_decoder_200.rknn \
    --text "Hello world" \
    --output output.wav \
    --max_length 200
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--encoder` | Encoder RKNN/ONNX 模型路径 | (必需) |
| `--decoder` | Decoder RKNN/ONNX 模型路径 | (必需) |
| `--text` | 要合成的文本 | (必需) |
| `--output` | 输出音频文件 | output.wav |
| `--max_length` | 最大输入长度 | 200 |

## 在 RK3576 板子上运行

### 重要说明

⚠️ **开发板和 PC 使用不同的 RKNN 包：**

| 环境 | 使用包 | 用途 |
|------|--------|------|
| PC (x86) | `rknn-toolkit2` | 模型转换、仿真测试 |
| RK3576 板子 | `rknn-toolkit-lite2` | 运行推理 |

### 步骤 1: 准备 rknn-toolkit-lite2

将 `rknn_toolkit_lite2-*.whl` 文件放在项目根目录下。

下载地址：https://github.com/airockchip/rknn-toolkit2/tree/master/rknn-toolkit-lite2/packages

选择对应 Python 版本的 wheel 文件，例如：
- Python 3.10: `rknn_toolkit_lite2-2.3.2-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl`
- Python 3.11: `rknn_toolkit_lite2-2.3.2-cp311-cp311-manylinux_2_17_aarch64.manylinux2014_aarch64.whl`

### 步骤 2: 运行安装脚本

```bash
chmod +x setup_board.sh
./setup_board.sh
```

脚本会自动：
1. 创建 Python 虚拟环境 `.venv`
2. 安装依赖 (soundfile, numpy, torch)
3. 从本地 wheel 文件安装 rknn-toolkit-lite2
4. 创建 `run.sh` 便捷运行脚本

### 步骤 3: 验证安装

```bash
source .venv/bin/activate
python -c "from rknnlite.api import RKNNLite; print('RKNN OK')"
```

### 步骤 4: 运行推理

```bash
# 激活虚拟环境
source .venv/bin/activate

# 使用便捷脚本
./run.sh --encoder model/mms_tts_eng_encoder_200.rknn --decoder model/mms_tts_eng_decoder_200.rknn --text "Hello from RK3576"

# 或直接运行
python3 python/mms_tts.py \
    --encoder model/mms_tts_eng_encoder_200.rknn \
    --decoder model/mms_tts_eng_decoder_200.rknn \
    --text "Hello world"
```

### 完整部署流程

```
┌─────────────────────────────────────────────────────────────┐
│                         PC (x86)                             │
│                                                              │
│  1. python3 -m venv .venv && source .venv/bin/activate      │
│  2. pip install rknn-toolkit2                                │
│  3. 运行 prepare_models.sh 准备 RKNN 模型                    │
│  4. 下载 rknn_toolkit_lite2-*.whl 到项目目录                 │
│  5. scp 复制整个项目到开发板                                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      RK3576 开发板                           │
│                                                              │
│  1. ./setup_board.sh (创建 venv + 安装依赖)                  │
│  2. source .venv/bin/activate                                │
│  3. ./run.sh --encoder ... --decoder ... --text "..."        │
└─────────────────────────────────────────────────────────────┘
```

## 关于中英文混合

MMS-TTS 是**单语言模型**，每个语言需要单独的模型文件。如需中英文混合：

### 方案 1: 分段合成后拼接

```python
import soundfile as sf
import numpy as np

# 分别用中英文模型合成
audio_en, sr = sf.read("english_part.wav")
audio_zh, sr = sf.read("chinese_part.wav")

# 拼接
combined = np.concatenate([audio_en, audio_zh])
sf.write("combined.wav", combined, sr)
```

### 方案 2: 使用多语言模型

推荐使用 [vits-melo-tts-zh_en](https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models)，原生支持中英文混合。

## 常见问题

### Q: 开发板上报错 "No module named 'rknn'"

这是最常见的问题！`rknn-toolkit-lite2` 使用的是 `rknnlite` 模块，而不是 `rknn` 模块。

**代码已自动适配**：mms_tts.py 会自动尝试两种导入方式：
1. 先尝试 `from rknn.api import RKNN` (PC 端)
2. 失败后尝试 `from rknnlite.api import RKNNLite as RKNN` (开发板)

**验证安装**：

```bash
source .venv/bin/activate

# 验证 rknnlite 模块
python -c "from rknnlite.api import RKNNLite; print('OK')"
# 应该显示: OK
```

**如果仍然失败**，请按以下步骤排查：

**步骤 1: 确认虚拟环境已激活**

```bash
source .venv/bin/activate
which python
# 应该显示: /path/to/mms_tts-rk3576/.venv/bin/python
```

**步骤 2: 确认 Python 版本与 wheel 文件匹配**

```bash
python --version
# 如果是 Python 3.11.x，需要使用 cp311 的 wheel 文件
# 如果是 Python 3.10.x，需要使用 cp310 的 wheel 文件
```

**步骤 3: 重新安装**

```bash
rm -rf .venv
./setup_board.sh
```

**步骤 4: 检查 wheel 文件**

```bash
ls -la rknn_toolkit_lite2-*.whl
# 文件名格式: rknn_toolkit_lite2-版本-cp版本-架构.whl
# 例如: rknn_toolkit_lite2-2.3.2-cp311-cp311-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
#       cp311 = Python 3.11
#       aarch64 = ARM 64位架构 (RK3576)
```

### Q: rknn_toolkit_lite2 wheel 文件哪里下载？

https://github.com/airockchip/rknn-toolkit2/tree/master/rknn-toolkit-lite2/packages

选择对应 Python 版本的文件：
- `cp310` = Python 3.10
- `cp311` = Python 3.11

### Q: PC 上准备模型时报错 "No module named 'rknn'"

```bash
source .venv/bin/activate
pip install rknn-toolkit2
```

### Q: 导出 ONNX 时报错 "No module named 'transformers'"

```bash
pip install transformers torch
```

### Q: RKNN 转换失败

确保使用 rknn-toolkit2 >= 2.0.0：

```bash
pip install rknn-toolkit2 --upgrade
```

### Q: 音频质量不好

尝试调整 max_length 参数，确保文本长度不超过设置值。

## 参考资料

- [rknn_model_zoo/examples/mms_tts](https://github.com/airockchip/rknn_model_zoo/tree/main/examples/mms_tts) - 官方示例
- [MMS-TTS HuggingFace](https://huggingface.co/facebook/mms-tts)
- [RKNN-Toolkit2](https://github.com/airockchip/rknn-toolkit2)

## 许可证

MMS-TTS 模型遵循其原始许可证 (CC BY-NC 4.0)。本项目代码遵循 MIT 许可证。
