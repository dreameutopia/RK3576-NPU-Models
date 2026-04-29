# Contributing to RK3576-NPU-Models

Thank you for your interest in contributing to RK3576-NPU-Models! 🎉

This document provides guidelines and information for contributing to this project.
Please read through this guide before submitting your first contribution.

> **语言提示**: 本文档为英文版贡献指南。中文版请参考 [README_zh.md](../README_zh.md#-参与贡献)。

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Adding New Models](#adding-new-models)
  - [Improving Documentation](#improving-documentation)
  - [Submitting Code Changes](#submitting-code-changes)
- [Development Environment](#development-environment)
- [Coding Standards](#coding-standards)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Model Contribution Guide](#model-contribution-guide)
- [Community](#community)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior via GitHub Issues.

---

## How to Contribute

### Reporting Bugs

If you find a bug, please [open a Bug Report](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=bug_report.yml) with the following information:

1. **Clear title and description** — Describe the bug concisely
2. **Steps to reproduce** — List the exact steps to trigger the bug
3. **Expected behavior** — What should have happened
4. **Actual behavior** — What actually happened
5. **Environment info** — Board model, OS version, RKNN toolkit version, conda environment
6. **Logs / Screenshots** — Any relevant error logs or screenshots

> 🔍 **Before submitting**, please search [existing issues](https://github.com/dreameutopia/RK3576-NPU-Models/issues) to avoid duplicates.

### Suggesting Features

Have an idea for improvement? [Open a Feature Request](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=feature_request.yml) with:

1. **Problem description** — What problem does this solve?
2. **Proposed solution** — How should it work?
3. **Alternatives considered** — Other approaches you've thought about
4. **Additional context** — Screenshots, references, etc.

### Adding New Models

Want to deploy a new model on RK3576? [Submit a Model Request](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=model_request.yml) with:

1. **Model name and link** — Original model repo or paper
2. **Use case** — What task does it perform?
3. **Estimated model size** — Parameter count / file size
4. **RKNN compatibility** — If known, any conversion challenges

### Improving Documentation

Documentation improvements are always welcome! You can:

- Fix typos or grammatical errors
- Add missing details to existing READMEs
- Translate documentation to other languages
- Add usage examples or tutorials

### Submitting Code Changes

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following our [coding standards](#coding-standards)
4. **Test** your changes (see [Development Environment](#development-environment))
5. **Commit** with a clear message following our [commit convention](#commit-message-convention)
6. **Push** to your fork and [open a Pull Request](#pull-request-process)

---

## Development Environment

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Git | 2.30+ | Version control |
| Conda | Latest | Python environment management |
| Python | 3.10 | Model conversion (rknn-toolkit2) |
| GCC (aarch64) | 10.2+ | Cross-compilation for RK3576 |
| CMake | 3.16+ | Build system |

### Setup

```bash
# 1. Fork and clone
git clone https://github.com/YOUR_USERNAME/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# 2. Add upstream remote
git remote add upstream https://github.com/dreameutopia/RK3576-NPU-Models.git

# 3. Clone dependency repos
chmod +x clone_repos.sh
./clone_repos.sh

# 4. Create conda environment
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4

# 5. Keep your fork updated
git fetch upstream
git rebase upstream/main
```

---

## Coding Standards

### C/C++ (Source Code)

- Follow the existing code style in the project
- Use **4-space indentation** (no tabs)
- Include header guards in all header files
- Add comments for complex logic, especially NPU-related code
- Use meaningful variable and function names

```cpp
// ✅ Good
rknn_tensor_attr input_attr;
input_attr.index = 0;
strncpy(input_attr.name, "input", sizeof(input_attr.name));

// ❌ Bad
rknn_tensor_attr a;
a.index = 0;
```

### Shell Scripts

- Start with `#!/bin/bash`
- Use `set -euo pipefail` for safety
- Quote all variables: `"${VARIABLE}"`
- Use descriptive function names
- Add usage help with `-h` flag

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 [-h] [-m MODEL_PATH]"
    echo "  -h  Show this help message"
    echo "  -m  Path to model file"
}
```

### CMake

- Use modern CMake (target-based approach)
- Set minimum required version explicitly
- Document cache variables and options

---

## Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Code style changes (formatting, semicolons, etc.) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or correcting tests |
| `chore` | Build process or auxiliary tool changes |
| `ci` | CI/CD configuration changes |

### Scopes

Use the model name or component as scope:

```
feat(ppocr): add batch image processing
fix(deepseek-ocr): resolve memory leak in image encoder
docs(qwen3-vl): add FP16 quantization guide
perf(lite-transformer): optimize NPU buffer allocation
chore(zipformer): update CMake build system
```

### Examples

```bash
# Good
git commit -m "feat(ppocr): add multi-language support for text detection"
git commit -m "fix(mms-tts): resolve audio output clipping on long sentences"
git commit -m "docs: update hardware requirements table"

# Bad
git commit -m "update code"
git commit -m "fix bug"
git commit -m "WIP"
```

---

## Pull Request Process

### Before Submitting

Please ensure your PR meets these requirements:

- [ ] Code compiles without errors
- [ ] All existing tests pass
- [ ] New tests added for new functionality (if applicable)
- [ ] Documentation updated (README, code comments)
- [ ] Commit messages follow [convention](#commit-message-convention)
- [ ] No large binary files (> 100MB) included — use Git LFS or `.gitignore`
- [ ] PR description clearly explains the change

### PR Template

When opening a PR, please fill out the [PR template](../.github/PULL_REQUEST_TEMPLATE.md) completely.

### Review Process

1. **Automated checks** — Ensure CI passes (if configured)
2. **Code review** — A maintainer will review your code
3. **Feedback** — Address any requested changes
4. **Approval** — Once approved, a maintainer will merge your PR

### After Merge

- Your contribution will be included in the next release
- You'll be added to the contributors list
- Consider starring the repo ⭐ to show your support!

---

## Model Contribution Guide

When adding a new model to this repository, please follow this structure:

### Directory Structure

```
your-model-rk3576/
├── README.md              # Model documentation (required)
├── build.sh               # Build script for on-board compilation
├── setup.sh               # Environment setup script
├── prepare_models.sh      # Model download/conversion script
├── CMakeLists.txt         # CMake build configuration
├── 3rdparty/              # Third-party dependencies
│   └── librknnrt/         # RKNN runtime libraries
├── include/               # Header files
├── lib/                   # Compiled libraries
├── src/                   # Source code
├── models/                # Model files directory
├── scripts/               # Test and utility scripts
│   ├── test_single.sh     # Single sample test
│   └── test_multi.sh      # Multi-sample test
└── test/                  # Test data
    ├── test1.png          # Sample input
    └── expected.txt       # Expected output (if applicable)
```

### Required Files

| File | Description |
|------|-------------|
| `README.md` | Full documentation including: description, benchmarks, setup, usage, FAQ |
| `build.sh` | Build script with cross-compilation support |
| `setup.sh` | Runtime environment setup |
| `prepare_models.sh` | Model download and RKNN conversion |
| `CMakeLists.txt` | CMake build configuration |
| `scripts/test_single.sh` | Basic functionality test |
| `src/main.cpp` | Entry point |

### README Template

Each model README should follow this structure:

```markdown
# Model Name - RK3576

Brief description and link to original model.

## Performance Benchmarks
- Latency: XX ms
- Memory: XX MB
- Throughput: XX samples/s

## Quick Start
### Prerequisites
### Build
### Run

## Model Details
- Input format
- Output format
- Quantization method

## FAQ
```

---

## Community

### Getting Help

- 📖 **Documentation** — Check the [main README](../README.md) and model-specific READMEs
- 🐛 **Bug Reports** — [Open an issue](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=bug_report.yml)
- 💡 **Feature Requests** — [Request a feature](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=feature_request.yml)
- 🧠 **Model Requests** — [Request a model](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=model_request.yml)

### Spreading the Word

If you find this project useful, please:

- ⭐ **Star** the repository
- 🍴 **Fork** and build upon it
- 📢 **Share** with others interested in edge AI
- 📝 **Write** about your experience using the models

---

Thank you for contributing to RK3576-NPU-Models! Your efforts help make edge AI more accessible. 🚀
