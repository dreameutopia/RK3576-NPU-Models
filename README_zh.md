<div align="center">

# RK3576 NPU 模型部署库

<img src="https://img.shields.io/badge/Platform-RK3576-orange?style=for-the-badge" alt="Platform">
<img src="https://img.shields.io/badge/NPU-6TOPS-green?style=for-the-badge" alt="NPU">
<img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge" alt="License">
<img src="https://img.shields.io/github/stars/dreameutopia/RK3576-NPU-Models?style=for-the-badge" alt="Stars">
<img src="https://img.shields.io/github/last-commit/dreameutopia/RK3576-NPU-Models?style=for-the-badge" alt="Last Commit">

**专为 [Radxa Rock 4D](https://radxa.com/products/rock4/4d) (RK3576) 验证、优化的 AI 模型 NPU 部署方案**

[English](./README.md) | **中文文档**

</div>

---

## ✨ 核心特性

- 🚀 **NPU 加速推理** — 充分利用 RK3576 6 TOPS 双核 NPU，实现边缘端高效推理
- 🔧 **开箱即用** — 提供完整的编译脚本、测试脚本和预转换模型
- 📦 **模块化设计** — 每个模型独立目录，按需部署，互不依赖
- 📝 **详尽文档** — 包含部署步骤、性能基准和常见问题解答
- 🔄 **持续更新** — 紧跟上游 [rknn-llm](https://github.com/airockchip/rknn-llm) 与 [rknn_model_zoo](https://github.com/airockchip/rknn_model_zoo) 更新

## 🗂️ 支持模型

| 模型 | 类别 | 功能 | 状态 |
|------|------|------|:----:|
| [PPOCRv4](./ppocr-rk3576) | OCR | PaddleOCR 文字检测与识别 | ✅ |
| [DeepSeek-OCR](./deepseek-ocr-rk3576) | 多模态 | DeepSeek 视觉 OCR 模型 | ✅ |
| [Qwen3-VL](./qwen3-vl-rk3576) | 多模态 | 通义千问视觉语言模型 | ✅ |
| [Lite Transformer](./lite_transformer-rk3576) | NLP | 轻量级英中翻译模型 | ✅ |
| [MMS-TTS](./mms_tts-rk3576) | TTS | 多语言语音合成模型 | ✅ |
| [Zipformer](./zipformer-rk3576) | ASR | 中英文语音识别模型 | ⚠️ |
| [Whisper](./whisper-rk3576) | ASR | OpenAI 语音识别模型 | ⚠️ |

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/dreameutopia/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# 克隆官方依赖仓库（必需）
chmod +x clone_repos.sh
./clone_repos.sh
```

### 2. 安装 rknn-toolkit2（模型转换）

```bash
# 创建 conda 环境
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

> 💡 也可使用一键配置脚本：`./setup_conda_env.sh`

### 3. 部署模型

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

## 📊 性能基准

### PPOCRv4 — 文字识别

| 指标 | 数值 |
|------|------|
| 检测延迟 | ~15 ms |
| 识别延迟 | ~8 ms/文本行 |
| 内存占用 | ~200 MB |

### Qwen3-VL — 多模态理解

| 阶段 | 耗时 |
|------|------|
| 图像编码 (448×448) | ~1.6 s |
| Prefill | ~1587 ms |
| Decode 速度 | ~10.36 tokens/s |
| 内存占用 | ~1.1 GB |

### Lite Transformer — 机器翻译

| 指标 | 数值 |
|------|------|
| 编码器延迟 | ~2 ms |
| 解码器延迟 | ~6–7 ms/步 |
| 总延迟 (4 词输出) | ~30–35 ms |

> 📌 更多基准数据请参考各模型目录下的 README。

## 📁 项目结构

```
RK3576-NPU-Models/
├── ppocr-rk3576/              # PPOCRv4 文字识别
├── deepseek-ocr-rk3576/       # DeepSeek-OCR 多模态
├── qwen3-vl-rk3576/           # Qwen3-VL 多模态大模型
├── lite_transformer-rk3576/   # Lite Transformer 翻译
├── mms_tts-rk3576/            # MMS-TTS 语音合成
├── zipformer-rk3576/          # Zipformer 语音识别
├── whisper-rk3576/            # Whisper 语音识别
├── .github/                   # GitHub 模板与工作流
│   ├── ISSUE_TEMPLATE/        # Bug / 功能 / 模型请求模板
│   └── PULL_REQUEST_TEMPLATE.md
├── clone_repos.sh             # 克隆依赖仓库脚本
├── setup_conda_env.sh         # Conda 环境一键配置
├── CONTRIBUTING_zh.md         # 贡献指南
├── CODE_OF_CONDUCT_zh.md      # 社区行为准则
├── SECURITY_zh.md             # 安全政策
├── CLONE_GUIDE.md             # 克隆指南
└── LICENSE                    # Apache 2.0
```

## 🔧 硬件要求

| 项目 | 最低要求 | 推荐 |
|------|----------|------|
| 开发板 | Radxa Rock 4D | Radxa Rock 4D |
| 可用内存 | 2 GB | 4 GB+ |
| 存储 | 4 GB | 8 GB+ |
| NPU | RK3576 (6 TOPS) | RK3576 (6 TOPS) |

## 📚 详细文档

| 模型 | 文档 |
|------|------|
| PPOCRv4 | [ppocr-rk3576/README.md](./ppocr-rk3576/README.md) |
| DeepSeek-OCR | [deepseek-ocr-rk3576/README.md](./deepseek-ocr-rk3576/README.md) |
| Qwen3-VL | [qwen3-vl-rk3576/README.md](./qwen3-vl-rk3576/README.md) |
| Lite Transformer | [lite_transformer-rk3576/README.md](./lite_transformer-rk3576/README.md) |
| MMS-TTS | [mms_tts-rk3576/README.md](./mms_tts-rk3576/README.md) |
| Zipformer | [zipformer-rk3576/README.md](./zipformer-rk3576/README.md) |
| Whisper | [whisper-rk3576/README.md](./whisper-rk3576/README.md) |

## 🛠️ 开发指南

### 交叉编译

```bash
./build.sh -c ~/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu
```

### NPU 提频（提升推理性能）

```bash
../rknn-llm/scripts/fix_freq_rk3576.sh
```

## ❓ 常见问题

<details>
<summary><b>setup.sh 找不到 rknn_model_zoo？</b></summary>

先运行 `./clone_repos.sh` 或手动指定路径：
```bash
./setup.sh -s /path/to/rknn-llm
```
</details>

<details>
<summary><b>prepare_models.sh 报错 "No module named 'pkg_resources'"？</b></summary>

```bash
pip install setuptools==69.0.0
```
</details>

<details>
<summary><b>运行时 "librknnrt.so: cannot open shared object file"？</b></summary>

```bash
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
```
</details>

## 🤝 参与贡献

我们欢迎各种形式的贡献！请在开始前阅读我们的贡献指南。

| 文档 | 说明 |
|------|------|
| [贡献指南](./CONTRIBUTING_zh.md) | 如何贡献代码、报告 Bug 和提交新模型 |
| [行为准则](./CODE_OF_CONDUCT_zh.md) | 社区规范与行为标准 |
| [安全政策](./SECURITY_zh.md) | 如何报告安全漏洞 |

### 快速入口

- 🐛 **发现了 Bug？** → [提交 Bug 报告](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=bug_report.md)
- ✨ **有功能建议？** → [提交功能请求](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=feature_request.md)
- 🧠 **想要新模型？** → [请求新模型](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=model_request.md)
- 💬 **有问题？** → [GitHub Discussions](https://github.com/dreameutopia/RK3576-NPU-Models/discussions)

### 贡献流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范提交 (`git commit -m 'feat(scope): add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 使用 [PR 模板](./.github/PULL_REQUEST_TEMPLATE.md)发起 Pull Request

> 📖 完整贡献指南请参阅 [CONTRIBUTING_zh.md](./CONTRIBUTING_zh.md)，包含模型贡献要求、代码风格和审核流程。

## 📄 许可证

本项目基于 [Apache 2.0](./LICENSE) 许可证开源。

## 🙏 致谢

- [rknn-llm](https://github.com/airockchip/rknn-llm) — Rockchip RKNN LLM 部署框架
- [rknn_model_zoo](https://github.com/airockchip/rknn_model_zoo) — Rockchip RKNN 模型库
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) — 百度开源 OCR 工具
- [Qwen](https://github.com/QwenLM/Qwen) — 阿里通义千问大模型
- [DeepSeek](https://github.com/deepseek-ai) — DeepSeek AI
- [Whisper](https://github.com/openai/whisper) — OpenAI 语音识别

---

<div align="center">

**如果这个项目对您有帮助，请给一个 ⭐ Star 支持一下！**

</div>