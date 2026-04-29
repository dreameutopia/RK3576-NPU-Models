# 贡献指南

感谢您对 RK3576-NPU-Models 项目的关注！本文档提供参与贡献的指南和规范。

> 📖 **Other Languages**: [English Contributing Guide](./CONTRIBUTING.md)

## 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
  - [报告 Bug](#报告-bug)
  - [提出功能建议](#提出功能建议)
  - [请求新模型](#请求新模型)
  - [提交代码](#提交代码)
- [开发环境搭建](#开发环境搭建)
- [模型贡献指南](#模型贡献指南)
- [Commit 消息规范](#commit-消息规范)
- [Pull Request 流程](#pull-request-流程)
- [代码风格指南](#代码风格指南)

---

## 行为准则

本项目遵循 [Contributor Covenant 行为准则](./CODE_OF_CONDUCT_zh.md)。参与贡献即表示您同意维护此准则。如遇不当行为，请向项目维护者报告。

---

## 如何贡献

### 报告 Bug

发现了 Bug？请[提交 Bug 报告](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=bug_report.md)，并包含以下信息：

1. **清晰的标题** — 简要概括问题
2. **环境信息** — 开发板型号、操作系统版本、RKNN toolkit 版本、conda 环境
3. **复现步骤** — 使用的完整命令和输入
4. **期望行为与实际行为** — 应该发生什么 vs 实际发生了什么
5. **日志信息** — 完整的错误输出、`dmesg` 日志或 NPU 运行时日志
6. **截图** — 如适用（特别是视觉模型输出结果）

> 💡 **提示**：请先搜索[已有 Issue](https://github.com/dreameutopia/RK3576-NPU-Models/issues) 以避免重复。

### 提出功能建议

有改进项目的建议？请[提交功能请求](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=feature_request.md)，描述：

1. **问题** — 您面临什么挑战？
2. **建议方案** — 应该如何工作？
3. **考虑过的替代方案** — 其他可能的方法

### 请求新模型

希望在 RK3576 上部署某个特定模型？请[提交模型请求](https://github.com/dreameutopia/RK3576-NPU-Models/issues/new?template=model_request.md)，提供：

1. **模型名称和来源** — 原始模型仓库或论文链接
2. **使用场景** — 解决什么任务？
3. **RKNN 兼容性** — 已知的 RKNN 转换状态或问题

### 提交代码

1. **检查已有 Issue** — 查找相关 Issue 或先创建一个进行讨论
2. **Fork 本仓库**
3. **从 `main` 创建特性分支**：
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **进行修改**（参见[代码风格指南](#代码风格指南)）
5. **在 RK3576 硬件上充分测试**
6. **提交**时使用 [Conventional Commits 规范](#commit-消息规范)
7. **推送**并发起 Pull Request

---

## 开发环境搭建

### 前置条件

- **宿主机**（x86_64）— 用于 rknn-toolkit2 模型转换
- **RK3576 开发板**（如 Radxa Rock 4D）— 用于板端编译和测试
- **Conda** — Python 环境管理

### 宿主机配置

```bash
# 1. 克隆仓库
git clone https://github.com/dreameutopia/RK3576-NPU-Models.git
cd RK3576-NPU-Models

# 2. 克隆依赖
chmod +x clone_repos.sh
./clone_repos.sh

# 3. 创建 conda 环境
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

### 开发板配置

```bash
# SSH 连接到 RK3576 开发板，然后：
cd /path/to/deployed-model
./setup.sh -s /path/to/rknn-llm
./build.sh
```

---

## 模型贡献指南

向本仓库添加新模型时，请遵循标准目录结构：

```
your-model-rk3576/
├── README.md              # 模型文档（必需）
├── CMakeLists.txt         # 构建配置
├── build.sh               # 编译脚本（支持交叉编译）
├── setup.sh               # 运行时环境配置脚本
├── prepare_models.sh      # 模型下载/转换脚本（如适用）
├── clean.sh               # 清理脚本（可选）
├── run.sh                 # 快速运行脚本（可选）
├── 3rdparty/              # 第三方依赖
│   ├── librknnrt/         # RKNN 运行时库
│   └── opencv/            # OpenCV 库（如需要）
├── include/               # 头文件
├── lib/                   # 编译后的库文件
│   └── aarch64/           # ARM64 编译库
├── src/                   # 源代码
├── model/                 # 模型文件（.rknn, .onnx 等）
├── onnx/                  # ONNX 模型文件（如适用）
├── scripts/               # 测试和工具脚本
│   ├── test_single.sh     # 单输入测试
│   └── test_multi.sh      # 批量测试
└── test/                  # 测试数据（图片、音频、文本）
```

### 模型 README 模板

每个模型目录**必须**包含一个 `README.md`，涵盖：

1. **模型描述** — 功能介绍、原始论文/仓库链接
2. **性能基准** — 在 RK3576 上的延迟、内存占用
3. **快速开始** — 逐步部署说明
4. **RKNN 转换方法** — 如何转换模型（量化细节）
5. **已知问题** — 任何限制或注意事项
6. **常见问题** — 常见问题及解决方案

### 测试要求

- **单元测试**：提供 `test_single.sh` 用于单输入验证
- **批量测试**：提供 `test_multi.sh` 用于吞吐量测试
- **测试数据**：在 `test/` 目录中包含示例输入（保持小体积）
- **硬件验证**：所有基准数据必须在实际 RK3576 硬件上测量

---

## Commit 消息规范

本项目遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范。每条 commit 消息应遵循以下格式：

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 类型（Type）

| 类型 | 说明 |
|------|------|
| `feat` | 新功能或新模型 |
| `fix` | Bug 修复 |
| `docs` | 仅文档变更 |
| `style` | 代码风格调整（格式化、缺少分号等） |
| `refactor` | 代码重构（不涉及功能变更） |
| `perf` | 性能优化 |
| `test` | 添加或更新测试 |
| `chore` | 构建流程或工具链变更 |
| `ci` | CI/CD 配置变更 |

### 范围（Scope）

适用时使用模型目录名作为范围：

- `ppocr` — PPOCRv4
- `deepseek-ocr` — DeepSeek-OCR
- `qwen3-vl` — Qwen3-VL
- `lite-transformer` — Lite Transformer
- `mms-tts` — MMS-TTS
- `zipformer` — Zipformer
- `whisper` — Whisper
- `repo` — 仓库级变更

### 示例

```
feat(qwen3-vl): add batch inference support
fix(ppocr): resolve memory leak in detection pipeline
docs(deepseek-ocr): add quantization benchmark results
perf(lite-transformer): optimize encoder with zero-copy NPU buffer
chore(repo): update .gitignore for model artifacts
```

---

## Pull Request 流程

### 提交前检查

- [ ] 代码在目标平台上编译无警告
- [ ] 所有测试在 RK3576 硬件上通过（`test_single.sh`、`test_multi.sh`）
- [ ] 文档已更新（README、代码注释）
- [ ] Commit 消息遵循 [Conventional Commits 规范](#commit-消息规范)
- [ ] 未添加大型二进制文件（> 100 MB 的模型文件使用 `.gitignore` 排除）
- [ ] 分支已与 `main` 保持同步

### PR 标题

使用与 Commit 相同的 Conventional Commits 格式：

```
feat(qwen3-vl): add FP16 quantization support
```

### 审核流程

1. 维护者将在 **7 天内** 审核您的 PR
2. 通过推送新 commit 来回应审核意见（审核期间避免 force-push）
3. 审核通过后，维护者将合并 PR
4. 您的贡献将在发布说明中获得致谢

### 审核要点

- **正确性** — 在 RK3576 上是否按预期工作？
- **性能** — NPU 资源是否高效利用？
- **文档** — 是否清晰完整？
- **代码质量** — 是否整洁、可读、结构良好？
- **向后兼容** — 是否会破坏现有功能？

---

## 代码风格指南

### C/C++ 代码

- 遵循 `src/` 目录中的现有代码风格
- 使用 **4 个空格** 缩进（不用 Tab）
- 为 NPU 相关操作添加描述性注释
- 尽可能使用 RAII 模式管理资源
- 头文件保护：`#pragma once` 或 `#ifndef MODEL_NAME_H_`

### Shell 脚本

- 使用 `#!/bin/bash` shebang
- 使用 `set -e` 进行错误处理
- 引用所有变量：`"${VARIABLE}"`
- 为面向用户的脚本添加使用说明/帮助信息

### Python 脚本

- 遵循 [PEP 8](https://peps.python.org/pep-0008/) 风格
- 尽可能使用类型注解
- 为公共函数添加 docstring

### 文档

- 使用 Markdown（`.md`）格式
- 每行不超过 100 个字符以保证可读性
- 包含带语法高亮的代码示例
- 尽可能同时提供中英文版本

---

## 问题反馈

- 💬 [GitHub Discussions](https://github.com/dreameutopia/RK3576-NPU-Models/discussions) — 一般性问题和建议讨论
- 🐛 [GitHub Issues](https://github.com/dreameutopia/RK3576-NPU-Models/issues) — Bug 报告和功能请求

---

<div align="center">

**感谢您让 RK3576-NPU-Models 变得更好！🚀**

</div>
