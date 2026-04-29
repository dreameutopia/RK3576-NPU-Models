<div align="center">

# RK3576 NPU Model Deployment

<img src="https://img.shields.io/badge/Platform-RK3576-orange?style=for-the-badge" alt="Platform">
<img src="https://img.shields.io/badge/NPU-6TOPS-green?style=for-the-badge" alt="NPU">
<img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge" alt="License">
<img src="https://img.shields.io/github/stars/dreameutopia/RK3576-NPU-Models?style=for-the-badge" alt="Stars">
<img src="https://img.shields.io/github/last-commit/dreameutopia/RK3576-NPU-Models?style=for-the-badge" alt="Last Commit">

**Verified & optimized AI model deployment on [Radxa Rock 4D](https://radxa.com/products/rock4/4d) (RK3576 NPU)**

**English** | [中文文档](./README_zh.md)

</div>

---

## ✨ Key Features

- 🚀 **NPU-Accelerated Inference** — Leverages RK3576 6 TOPS dual-core NPU for efficient edge inference
- 🔧 **Ready to Use** — Complete build scripts, test scripts, and pre-converted models included
- 📦 **Modular Design** — Each model in an independent directory, deploy only what you need
- 📝 **Well Documented** — Step-by-step deployment guides, benchmarks, and FAQs
- 🔄 **Actively Maintained** — Tracking upstream [rknn-llm](https://github.com/airockchip/rknn-llm) & [rknn_model_zoo](https://github.com/airockchip/rknn_model_zoo)

## 🗂️ Supported Models

| Model | Category | Description | Status |
|-------|----------|-------------|:------:|
| [PPOCRv4](./ppocr-rk3576) | OCR | PaddleOCR text detection & recognition | ✅ |
| [DeepSeek-OCR](./deepseek-ocr-rk3576) | Multimodal | DeepSeek visual OCR model | ✅ |
| [Qwen3-VL](./qwen3-vl-rk3576) | Multimodal | Qwen Vision-Language model | ✅ |
| [Lite Transformer](./lite_transformer-rk3576) | NLP | Lightweight EN↔CN translation | ✅ |
| [MMS-TTS](./mms_tts-rk3576) | TTS | Multilingual speech synthesis | ✅ |
| [Zipformer](./zipformer-rk3576) | ASR | Chinese & English speech recognition | ⚠️ |
| [Whisper](./whisper-rk3576) | ASR | OpenAI Whisper speech recognition | ⚠️ |

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/dreameutopia/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# Clone dependency repos (required)
chmod +x clone_repos.sh
./clone_repos.sh
```

### 2. Install rknn-toolkit2 (Model Conversion)

```bash
# Create conda environment
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

> 💡 Or use the one-step setup: `./setup_conda_env.sh`

### 3. Deploy a Model

Example — **PPOCRv4**:

```bash
cd ppocr-rk3576

# Prepare models (requires rknn3 environment)
conda activate rknn3
./prepare_models.sh

# Setup runtime libraries
./setup.sh -s ../rknn-llm

# Build on the RK3576 board
./build.sh

# Run test
./scripts/test_single.sh -i test/test1.png
```

## 📊 Benchmarks

### PPOCRv4 — Text Recognition

| Metric | Value |
|--------|-------|
| Detection Latency | ~15 ms |
| Recognition Latency | ~8 ms / text line |
| Memory Usage | ~200 MB |

### Qwen3-VL — Multimodal Understanding

| Stage | Time |
|-------|------|
| Image Encoding (448×448) | ~1.6 s |
| Prefill | ~1587 ms |
| Decode Speed | ~10.36 tokens/s |
| Memory Usage | ~1.1 GB |

### Lite Transformer — Machine Translation

| Metric | Value |
|--------|-------|
| Encoder Latency | ~2 ms |
| Decoder Latency | ~6–7 ms / step |
| Total Latency (4-word output) | ~30–35 ms |

> 📌 See individual model READMEs for detailed benchmarks.

## 📁 Project Structure

```
RK3576-NPU-Models/
├── ppocr-rk3576/              # PPOCRv4 text recognition
├── deepseek-ocr-rk3576/       # DeepSeek-OCR multimodal
├── qwen3-vl-rk3576/           # Qwen3-VL multimodal LLM
├── lite_transformer-rk3576/   # Lite Transformer translation
├── mms_tts-rk3576/            # MMS-TTS speech synthesis
├── zipformer-rk3576/          # Zipformer speech recognition
├── whisper-rk3576/            # Whisper speech recognition
├── .github/                   # GitHub templates & workflows
│   ├── ISSUE_TEMPLATE/        # Bug / Feature / Model request templates
│   └── PULL_REQUEST_TEMPLATE.md
├── clone_repos.sh             # Dependency repos clone script
├── setup_conda_env.sh         # One-step conda environment setup
├── CONTRIBUTING.md            # Contributing guide
├── CODE_OF_CONDUCT.md         # Community code of conduct
├── SECURITY.md                # Security policy
├── CLONE_GUIDE.md             # Cloning guide
└── LICENSE                    # Apache 2.0
```

## 🔧 Hardware Requirements

| Item | Minimum | Recommended |
|------|---------|-------------|
| Board | Radxa Rock 4D | Radxa Rock 4D |
| Available Memory | 2 GB | 4 GB+ |
| Storage | 4 GB | 8 GB+ |
| NPU | RK3576 (6 TOPS) | RK3576 (6 TOPS) |

## 📚 Documentation

| Model | Documentation |
|-------|---------------|
| PPOCRv4 | [ppocr-rk3576/README.md](./ppocr-rk3576/README.md) |
| DeepSeek-OCR | [deepseek-ocr-rk3576/README.md](./deepseek-ocr-rk3576/README.md) |
| Qwen3-VL | [qwen3-vl-rk3576/README.md](./qwen3-vl-rk3576/README.md) |
| Lite Transformer | [lite_transformer-rk3576/README.md](./lite_transformer-rk3576/README.md) |
| MMS-TTS | [mms_tts-rk3576/README.md](./mms_tts-rk3576/README.md) |
| Zipformer | [zipformer-rk3576/README.md](./zipformer-rk3576/README.md) |
| Whisper | [whisper-rk3576/README.md](./whisper-rk3576/README.md) |

## 🛠️ Development

### Cross Compilation

```bash
./build.sh -c ~/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu
```

### NPU Frequency Boost

```bash
../rknn-llm/scripts/fix_freq_rk3576.sh
```

## ❓ FAQ

<details>
<summary><b>setup.sh cannot find rknn_model_zoo?</b></summary>

Run `./clone_repos.sh` first, or specify the path manually:
```bash
./setup.sh -s /path/to/rknn-llm
```
</details>

<details>
<summary><b>prepare_models.sh fails with "No module named 'pkg_resources'"?</b></summary>

```bash
pip install setuptools==69.0.0
```
</details>

<details>
<summary><b>Runtime error "librknnrt.so: cannot open shared object file"?</b></summary>

```bash
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
```
</details>

## 🤝 Contributing

We welcome contributions of all kinds! Please read our guidelines before getting started.

| Document | Description |
|----------|-------------|
| [Contributing Guide](./CONTRIBUTING.md) | How to contribute code, report bugs, and submit models |
| [Code of Conduct](./CODE_OF_CONDUCT.md) | Community standards and expectations |
| [Security Policy](./SECURITY.md) | How to report vulnerabilities |

### Quick Links

- 🐛 **Found a bug?** → [Open a Bug Report](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=bug_report.md)
- ✨ **Have a feature idea?** → [Submit a Feature Request](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=feature_request.md)
- 🧠 **Want a new model?** → [Request a Model](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=model_request.md)
- 💬 **Questions?** → [GitHub Discussions](https://github.com/dreameutopia/RK3576-NPU-Models/discussions)

### Contributing Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/) (`git commit -m 'feat(scope): add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request using the [PR template](./.github/PULL_REQUEST_TEMPLATE.md)

> 📖 See the full [Contributing Guide](./CONTRIBUTING.md) for model contribution requirements, code style, and review process.

## 📄 License

This project is licensed under the [Apache 2.0](./LICENSE) License.

## 🙏 Acknowledgments

- [rknn-llm](https://github.com/airockchip/rknn-llm) — Rockchip RKNN LLM deployment framework
- [rknn_model_zoo](https://github.com/airockchip/rknn_model_zoo) — Rockchip RKNN model zoo
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) — Baidu open-source OCR toolkit
- [Qwen](https://github.com/QwenLM/Qwen) — Alibaba Qwen LLM
- [DeepSeek](https://github.com/deepseek-ai) — DeepSeek AI
- [Whisper](https://github.com/openai/whisper) — OpenAI speech recognition

---

<div align="center">

**If this project helps you, please consider giving it a ⭐ Star!**

</div>