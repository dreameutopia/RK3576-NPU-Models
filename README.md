<div align="center">

# RK3576-NPU-Models

<img src="https://img.shields.io/badge/Platform-RK3576-orange?style=for-the-badge" alt="Platform">
<img src="https://img.shields.io/badge/NPU-Accelerated-green?style=for-the-badge" alt="NPU">
<img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge" alt="License">
<img src="https://img.shields.io/github/stars/dreameutopia/RK3576-NPU-Models?style=for-the-badge" alt="Stars">

**专为 Radxa Rock 4D (RK3576) 验证、设计、适配的 AI 模型部署库**

[English](#english-documentation) | [中文文档](#中文文档)

</div>

---

## 中文文档

### 📖 项目简介

本项目提供了一系列主流 AI 模型在 **RK3576 NPU** 平台上的完整部署方案，涵盖语音识别、光学字符识别、机器翻译、多模态大模型等多个领域。所有模型均经过验证优化，可直接在 Radxa Rock 4D 开发板上运行。

### ✨ 核心特性

- 🚀 **NPU 加速推理** - 充分利用 RK3576 双核 NPU，实现高效推理
- 🔧 **开箱即用** - 提供完整的编译脚本、测试脚本和预转换模型
- 📦 **模块化设计** - 每个模型独立目录，便于按需使用
- 📝 **详尽文档** - 包含详细的使用说明、性能基准和常见问题解答
- 🔄 **持续更新** - 紧跟上游 rknn-llm 和 rknn_model_zoo 更新

### 🗂️ 模型列表

| 模型 | 类型 | 功能描述 | 状态 |
|------|------|----------|------|
| [PPOCRv4](./ppocr-rk3576) | OCR | PaddleOCR 文字检测与识别 | ✅ 已验证 |
| [Qwen3-VL](./qwen3-vl-rk3576) | 多模态 | 通义千问视觉语言模型 | ✅ 已验证 |
| [DeepSeek-OCR](./deepseek-ocr-rk3576) | 多模态 | DeepSeek OCR 专用模型 | ✅ 已验证 |
| [Lite Transformer](./lite_transformer-rk3576) | NLP | 轻量级英中翻译模型 | ✅ 已验证 |
| [Zipformer](./zipformer-rk3576) | ASR | 中英文语音识别模型 | ⚠️ 待验证 |

### 🚀 快速开始

#### 1. 环境准备

```bash
# 克隆仓库
git clone https://github.com/dreameutopia/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# 克隆官方依赖仓库（必需）
chmod +x clone_repos.sh
./clone_repos.sh
```

#### 2. 安装 rknn-toolkit2（模型转换）

```bash
# 创建 conda 环境
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

#### 3. 选择模型部署

以 **PPOCRv4** 为例：

```bash
cd ppocr-rk3576

# 准备模型（需要 rknn3 环境）
conda activate rknn3
./prepare_models.sh

# 准备运行时库
./setup.sh -s ../rknn-llm

# 编译（在 RK3576 开发板上执行）
./build.sh

# 测试
./scripts/test_single.sh -i test/test1.png
```

### 📊 性能基准

#### PPOCRv4 (文字识别)

| 指标 | 数值 |
|------|------|
| 检测模型延迟 | ~15ms |
| 识别模型延迟 | ~8ms/文本行 |
| 内存占用 | ~200MB |

#### Qwen3-VL (多模态理解)

| 阶段 | 耗时 |
|------|------|
| 图像编码 (448×448) | ~1.6s |
| Prefill | ~1587ms |
| Decode 速度 | ~10.36 tokens/s |
| 内存占用 | ~1.1GB |

#### Lite Transformer (机器翻译)

| 指标 | 数值 |
|------|------|
| 编码器延迟 | ~2ms |
| 解码器延迟 | ~6-7ms/步 |
| 总延迟 (4词输出) | ~30-35ms |

### 📁 项目结构

```
RK3576-NPU-Models/
├── ppocr-rk3576/              # PPOCRv4 文字识别
│   ├── src/                   # 源代码
│   ├── model/                 # RKNN 模型
│   ├── scripts/               # 测试脚本
│   └── 3rdparty/              # 依赖库
├── qwen3-vl-rk3576/           # Qwen3-VL 多模态
├── deepseek-ocr-rk3576/       # DeepSeek-OCR
├── lite_transformer-rk3576/   # Lite Transformer 翻译
├── zipformer-rk3576/          # Zipformer 语音识别
├── clone_repos.sh             # 克隆依赖仓库脚本
├── setup_conda_env.sh         # Conda 环境配置
└── CLONE_GUIDE.md             # 克隆指南
```

### 🔧 硬件要求

| 项目 | 最低要求 | 推荐配置 |
|------|----------|----------|
| 开发板 | Radxa Rock 4D | Radxa Rock 4D |
| 内存 | 2GB 可用 | 4GB+ 可用 |
| 存储 | 4GB | 8GB+ |
| NPU | RK3576 双核 | RK3576 双核 |

### 📚 详细文档

每个模型都有独立的 README 文档，包含：

- 完整的目录结构说明
- 详细的部署步骤
- 运行参数配置
- 性能优化建议
- 常见问题解答

| 模型 | 文档链接 |
|------|----------|
| PPOCRv4 | [ppocr-rk3576/README.md](./ppocr-rk3576/README.md) |
| Qwen3-VL | [qwen3-vl-rk3576/README.md](./qwen3-vl-rk3576/README.md) |
| DeepSeek-OCR | [deepseek-ocr-rk3576/README.md](./deepseek-ocr-rk3576/README.md) |
| Lite Transformer | [lite_transformer-rk3576/README.md](./lite_transformer-rk3576/README.md) |
| Zipformer | [zipformer-rk3576/README.md](./zipformer-rk3576/README.md) |

### 🛠️ 开发指南

#### 交叉编译

```bash
# 在 PC 上交叉编译
./build.sh -c ~/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu
```

#### 模型转换

如需自行转换模型，请参考各模型目录下的 README 文档中的「模型转换」章节。

#### 性能优化建议

1. **NPU 提频** - 运行前执行提频脚本：
   ```bash
   ../rknn-llm/scripts/fix_freq_rk3576.sh
   ```

2. **内存优化** - 确保设备有足够的可用内存

3. **核心数配置** - RK3576 有 2 个 NPU 核心，RK3588 有 3 个

### ❓ 常见问题

<details>
<summary><b>Q: setup.sh 报错找不到 rknn_model_zoo？</b></summary>

确保先运行 `./clone_repos.sh` 克隆依赖仓库，或手动指定路径：
```bash
./setup.sh -s /path/to/rknn-llm
```
</details>

<details>
<summary><b>Q: prepare_models.sh 报错 "No module named 'pkg_resources'"？</b></summary>

安装正确版本的 setuptools：
```bash
pip install setuptools==69.0.0
```
</details>

<details>
<summary><b>Q: 运行时报错 "librknnrt.so: cannot open shared object file"？</b></summary>

设置正确的库路径：
```bash
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
```
</details>

<details>
<summary><b>Q: 如何获取更好的推理性能？</b></summary>

1. 运行 NPU 提频脚本
2. 确保有足够的可用内存（建议 ≥2GB）
3. 根据平台设置正确的 NPU 核心数
</details>

### 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 📄 许可证

本项目采用 Apache 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

### 🙏 致谢

本项目基于以下开源项目构建：

- [rknn-llm](https://github.com/airockchip/rknn-llm) - Rockchip RKNN LLM 部署框架
- [rknn_model_zoo](https://github.com/airockchip/rknn_model_zoo) - Rockchip RKNN 模型库
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) - 百度开源 OCR 工具
- [Qwen](https://github.com/QwenLM/Qwen) - 阿里通义千问大模型
- [DeepSeek](https://github.com/deepseek-ai) - DeepSeek AI 模型

---

## English Documentation

### 📖 Overview

This project provides complete deployment solutions for mainstream AI models on the **RK3576 NPU** platform, covering speech recognition, optical character recognition, machine translation, and multimodal large models. All models have been verified and optimized to run directly on Radxa Rock 4D development boards.

### ✨ Key Features

- 🚀 **NPU Accelerated Inference** - Fully utilize RK3576's dual-core NPU for efficient inference
- 🔧 **Ready to Use** - Complete build scripts, test scripts, and pre-converted models
- 📦 **Modular Design** - Each model in independent directory for flexible usage
- 📝 **Comprehensive Documentation** - Detailed usage instructions, benchmarks, and FAQ
- 🔄 **Continuous Updates** - Following upstream rknn-llm and rknn_model_zoo updates

### 🗂️ Model List

| Model | Type | Description | Status |
|-------|------|-------------|--------|
| [PPOCRv4](./ppocr-rk3576) | OCR | PaddleOCR text detection & recognition | ✅ Verified |
| [Qwen3-VL](./qwen3-vl-rk3576) | Multimodal | Qwen Vision-Language model | ✅ Verified |
| [DeepSeek-OCR](./deepseek-ocr-rk3576) | Multimodal | DeepSeek OCR specialized model | ✅ Verified |
| [Lite Transformer](./lite_transformer-rk3576) | NLP | Lightweight EN-CN translation | ✅ Verified |
| [Zipformer](./zipformer-rk3576) | ASR | Chinese-English speech recognition | ⚠️ Pending |

### 🚀 Quick Start

#### 1. Environment Setup

```bash
# Clone repository
git clone https://github.com/dreameutopia/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# Clone official dependency repositories (required)
chmod +x clone_repos.sh
./clone_repos.sh
```

#### 2. Install rknn-toolkit2 (for model conversion)

```bash
# Create conda environment
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

#### 3. Deploy a Model

Example with **PPOCRv4**:

```bash
cd ppocr-rk3576

# Prepare models (requires rknn3 environment)
conda activate rknn3
./prepare_models.sh

# Setup runtime libraries
./setup.sh -s ../rknn-llm

# Build (on RK3576 board)
./build.sh

# Test
./scripts/test_single.sh -i test/test1.png
```

### 📊 Performance Benchmarks

#### PPOCRv4 (Text Recognition)

| Metric | Value |
|--------|-------|
| Detection Latency | ~15ms |
| Recognition Latency | ~8ms/text line |
| Memory Usage | ~200MB |

#### Qwen3-VL (Multimodal Understanding)

| Stage | Time |
|-------|------|
| Image Encoding (448×448) | ~1.6s |
| Prefill | ~1587ms |
| Decode Speed | ~10.36 tokens/s |
| Memory Usage | ~1.1GB |

#### Lite Transformer (Machine Translation)

| Metric | Value |
|--------|-------|
| Encoder Latency | ~2ms |
| Decoder Latency | ~6-7ms/step |
| Total Latency (4-word output) | ~30-35ms |

### 🔧 Hardware Requirements

| Item | Minimum | Recommended |
|------|---------|-------------|
| Board | Radxa Rock 4D | Radxa Rock 4D |
| Memory | 2GB available | 4GB+ available |
| Storage | 4GB | 8GB+ |
| NPU | RK3576 dual-core | RK3576 dual-core |

### 📚 Documentation

Each model has its own README with detailed instructions:

| Model | Documentation |
|-------|---------------|
| PPOCRv4 | [ppocr-rk3576/README.md](./ppocr-rk3576/README.md) |
| Qwen3-VL | [qwen3-vl-rk3576/README.md](./qwen3-vl-rk3576/README.md) |
| DeepSeek-OCR | [deepseek-ocr-rk3576/README.md](./deepseek-ocr-rk3576/README.md) |
| Lite Transformer | [lite_transformer-rk3576/README.md](./lite_transformer-rk3576/README.md) |
| Zipformer | [zipformer-rk3576/README.md](./zipformer-rk3576/README.md) |

### 🤝 Contributing

Contributions are welcome! Please feel free to submit Issues and Pull Requests.

### 📄 License

This project is licensed under the Apache 2.0 License.

### 🙏 Acknowledgments

Built upon these open-source projects:

- [rknn-llm](https://github.com/airockchip/rknn-llm)
- [rknn_model_zoo](https://github.com/airockchip/rknn_model_zoo)
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR)
- [Qwen](https://github.com/QwenLM/Qwen)
- [DeepSeek](https://github.com/deepseek-ai)

---

<div align="center">

**如果这个项目对您有帮助，请给一个 ⭐ Star 支持一下！**

**If this project helps you, please give it a ⭐ Star!**

</div>
