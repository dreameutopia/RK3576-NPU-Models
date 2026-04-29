# Contributing to RK3576-NPU-Models

Thank you for your interest in contributing to RK3576-NPU-Models! This document provides guidelines and information about contributing to this project.

> 📖 **Other Languages**: [中文贡献指南](./CONTRIBUTING_zh.md)

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Requesting New Models](#requesting-new-models)
  - [Submitting Code](#submitting-code)
- [Development Setup](#development-setup)
- [Model Contribution Guide](#model-contribution-guide)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you agree to uphold this code. Please report unacceptable behavior to the project maintainers.

---

## How to Contribute

### Reporting Bugs

Found a bug? Please [open a Bug Report](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=bug_report.md) and include:

1. **Clear title** — Summarize the issue concisely
2. **Environment info** — Board model, OS version, RKNN toolkit version, conda environment
3. **Steps to reproduce** — Exact commands and inputs used
4. **Expected vs actual behavior** — What should happen vs what happened
5. **Logs** — Full error output, `dmesg` logs, or NPU runtime logs
6. **Screenshots** — If applicable (especially for visual model outputs)

> 💡 **Tip**: Search [existing issues](https://github.com/dreameutopia/RK3576-NPU-Models/issues) first to avoid duplicates.

### Suggesting Features

Have an idea to improve the project? [Open a Feature Request](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=feature_request.md) and describe:

1. **The problem** — What challenge are you facing?
2. **Proposed solution** — How should it work?
3. **Alternatives considered** — Other approaches you've thought about

### Requesting New Models

Want to see a specific model deployed on RK3576? [Open a Model Request](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=model_request.md) and provide:

1. **Model name and source** — Link to the original model repo or paper
2. **Use case** — What task does it solve?
3. **RKNN compatibility** — Any known RKNN conversion status or issues

### Submitting Code

1. **Check existing issues** — Look for related issues or create one first to discuss
2. **Fork the repository**
3. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** (see [Style Guide](#style-guide))
5. **Test thoroughly** on RK3576 hardware
6. **Commit** using [conventional commits](#commit-message-convention)
7. **Push** and open a Pull Request

---

## Development Setup

### Prerequisites

- **Host machine** (x86_64) — For model conversion with rknn-toolkit2
- **RK3576 board** (e.g., Radxa Rock 4D) — For on-device compilation and testing
- **Conda** — Python environment management

### Host Setup

```bash
# 1. Clone the repo
git clone https://github.com/dreameutopia/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# 2. Clone dependencies
chmod +x clone_repos.sh
./clone_repos.sh

# 3. Create conda environment
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

### Board Setup

```bash
# SSH to your RK3576 board, then:
cd /path/to/deployed-model
./setup.sh -s /path/to/rknn-llm
./build.sh
```

---

## Model Contribution Guide

To add a new model to this repository, follow the standard directory structure:

```
your-model-rk3576/
├── README.md              # Model-specific documentation (required)
├── CMakeLists.txt         # Build configuration
├── build.sh               # Build script (cross-compile support)
├── setup.sh               # Runtime setup script
├── prepare_models.sh      # Model download / conversion script (if applicable)
├── clean.sh               # Cleanup script (optional)
├── run.sh                 # Quick run script (optional)
├── 3rdparty/              # Third-party dependencies
│   ├── librknnrt/         # RKNN runtime libraries
│   └── opencv/            # OpenCV libraries (if needed)
├── include/               # Header files
├── lib/                   # Compiled libraries
│   └── aarch64/           # ARM64 compiled libraries
├── src/                   # Source code
├── model/                 # Model files (.rknn, .onnx, etc.)
├── onnx/                  # ONNX model files (if applicable)
├── scripts/               # Test and utility scripts
│   ├── test_single.sh     # Single input test
│   └── test_multi.sh      # Batch test
└── test/                  # Test data (images, audio, text)
```

### Model README Template

Each model directory **must** include a `README.md` with:

1. **Model description** — What it does, original paper/repo link
2. **Performance benchmarks** — Latency, memory usage on RK3576
3. **Quick start** — Step-by-step deployment instructions
4. **RKNN conversion** — How to convert the model (quantization details)
5. **Known issues** — Any limitations or caveats
6. **FAQ** — Common problems and solutions

### Testing Requirements

- **Unit tests**: Provide `test_single.sh` for single-input validation
- **Batch tests**: Provide `test_multi.sh` for throughput testing
- **Test data**: Include sample inputs in `test/` directory (keep small)
- **Hardware validation**: All benchmarks must be measured on actual RK3576 hardware

---

## Commit Message Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/). Each commit message should be structured as:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature or model |
| `fix` | A bug fix |
| `docs` | Documentation changes only |
| `style` | Code style changes (formatting, missing semicolons, etc.) |
| `refactor` | Code refactoring without feature changes |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `chore` | Build process or tooling changes |
| `ci` | CI/CD configuration changes |

### Scopes

Use the model directory name as the scope when applicable:

- `ppocr` — PPOCRv4
- `deepseek-ocr` — DeepSeek-OCR
- `qwen3-vl` — Qwen3-VL
- `lite-transformer` — Lite Transformer
- `mms-tts` — MMS-TTS
- `zipformer` — Zipformer
- `whisper` — Whisper
- `repo` — Repository-level changes

### Examples

```
feat(qwen3-vl): add batch inference support
fix(ppocr): resolve memory leak in detection pipeline
docs(deepseek-ocr): add quantization benchmark results
perf(lite-transformer): optimize encoder with zero-copy NPU buffer
chore(repo): update .gitignore for model artifacts
```

---

## Pull Request Process

### Before Submitting

- [ ] Code compiles without warnings on the target platform
- [ ] All tests pass on RK3576 hardware (`test_single.sh`, `test_multi.sh`)
- [ ] Documentation is updated (README, code comments)
- [ ] Commit messages follow [conventional commits](#commit-message-convention)
- [ ] No large binary files added (use `.gitignore` for model artifacts > 100 MB)
- [ ] Branch is up to date with `main`

### PR Title

Use the same conventional commit format for PR titles:

```
feat(qwen3-vl): add FP16 quantization support
```

### Review Process

1. A maintainer will review your PR within **7 days**
2. Address review comments by pushing new commits (avoid force-push during review)
3. Once approved, a maintainer will merge your PR
4. Your contribution will be credited in the release notes

### What We Look For

- **Correctness** — Does it work as described on RK3576?
- **Performance** — Are NPU resources utilized efficiently?
- **Documentation** — Is it clear and complete?
- **Code quality** — Clean, readable, and well-structured
- **Backward compatibility** — Does it break existing functionality?

---

## Style Guide

### C/C++ Code

- Follow the existing code style in `src/` directories
- Use **4 spaces** for indentation (no tabs)
- Include descriptive comments for NPU-specific operations
- Use RAII patterns for resource management where possible
- Header guards: `#pragma once` or `#ifndef MODEL_NAME_H_`

### Shell Scripts

- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Quote all variables: `"${VARIABLE}"`
- Add usage/help messages for user-facing scripts

### Python Scripts

- Follow [PEP 8](https://peps.python.org/pep-0008/) style
- Use type hints where practical
- Include docstrings for public functions

### Documentation

- Use Markdown (`.md`) format
- Keep line width ≤ 100 characters for readability
- Include code examples with syntax highlighting
- Provide both English and Chinese versions when possible

---

## Questions?

- 💬 [GitHub Discussions](https://github.com/dreameutopia/RK3576-NPU-Models/discussions) — For general questions and ideas
- 🐛 [GitHub Issues](https://github.com/dreameutopia/RK3576-NPU-Models/issues) — For bug reports and feature requests

---

<div align="center">

**Thank you for making RK3576-NPU-Models better! 🚀**

</div>
