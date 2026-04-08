# Lite Transformer RK3576 部署包

Lite Transformer 英中翻译模型在 RK3576 平台的完整部署方案。

## 简介

Lite Transformer 是一个轻量级的 Transformer 模型，专门用于机器翻译任务。本项目将其部署到 RK3576 平台，利用 NPU 加速实现高效的英中翻译。

模型来源: [airockchip/lite-transformer](https://github.com/airockchip/lite-transformer)

## 目录结构

```
lite_transformer-rk3576/
├── setup.sh              # 依赖设置脚本（从 rknn_model_zoo 复制文件）
├── build.sh              # 编译脚本
├── run.sh                # 快速运行脚本
├── clean.sh              # 清理脚本
├── CMakeLists.txt        # CMake 配置（由 setup.sh 生成）
├── src/                  # 源代码（由 setup.sh 复制）
│   ├── main.cc
│   ├── lite_transformer.h
│   ├── rknpu2/
│   │   ├── lite_transformer.cc
│   │   └── rkdemo_utils/
│   └── utils/
├── scripts/              # 测试脚本
│   ├── test_single.sh    # 单句测试
│   └── test_multi.sh     # 多句测试
├── 3rdparty/             # 依赖库（由 setup.sh 复制）
├── model/                # 模型文件（由 setup.sh 复制）
└── install/              # 编译输出
```

## 快速开始

### 步骤 1: 设置依赖

**重要：此步骤需要在有 rknn_model_zoo 的环境中执行！**

```bash
# 设置 rknn_model_zoo 路径（默认为 ../rknn_model_zoo）
./setup.sh

# 或指定路径
RKNN_MODEL_ZOO_PATH=/path/to/rknn_model_zoo ./setup.sh
```

setup.sh 会复制以下文件：
- RKNN 运行时库和头文件
- timer 工具
- 源代码文件
- 字典和 embedding 文件
- RKNN 模型文件

### 步骤 2: 编译

```bash
# 在 RK3576 板子上编译
./build.sh

# 或交叉编译
./build.sh -c /path/to/aarch64-none-linux-gnu-gcc
```

### 步骤 3: 测试

```bash
# 单句翻译
./scripts/test_single.sh -t "thank you"

# 多句测试
./scripts/test_multi.sh
```

### 步骤 4: 清理

```bash
./clean.sh
```

## 运行示例

```bash
cd install
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
./rknn_lite_transformer_demo model/lite-transformer-encoder-16.rknn model/lite-transformer-decoder-16.rknn "thank you"
```

## 预期输出

```
bpe preprocess use: 0.063000 ms
rknn encoder run use: 2.037000 ms
rknn decoder once run use: 6.686000 ms
decoder run 4 times. cost use: 30.348000 ms
inference time use: 33.730999 ms
output_strings: 感谢你
```

## 模型说明

### 模型架构

Lite Transformer 采用标准的 Encoder-Decoder 架构：

- **Encoder**: 将输入的英文文本编码为语义向量
- **Decoder**: 根据编码器的输出生成中文翻译（增量推理）

### 模型参数

| 参数 | 值 |
|------|-----|
| 注意力头数 | 4 |
| 嵌入维度 | 256 |
| 解码器层数 | 3 |
| 最大句子长度 | 16 |
| 词表大小 | ~36808 |

### 性能参考

| 平台 | 编码器延迟 | 解码器延迟 (每步) | 总延迟 (4词输出) |
|------|-----------|-----------------|-----------------|
| RK3576 | ~2 ms | ~6-7 ms | ~30-35 ms |

## 技术细节

### 为什么需要 setup.sh？

Lite Transformer 的 decoder 使用了增量推理，需要处理 key/value 缓存。这需要：

1. **10 个输入**：
   - 输入 0: decoder embedding
   - 输入 1: encoder output
   - 输入 2: encoder mask
   - 输入 3: decoder mask
   - 输入 4-9: key/value 缓存（6 个）

2. **7 个输出**：
   - 输出 0: 预测的 token 概率
   - 输出 1-6: 更新后的 key/value 缓存

3. **NC1HWC2 内存布局**：key/value 缓存使用特殊的内存布局

4. **Zero-Copy API**：需要使用 `rknn_set_io_mem` 而不是 `rknn_inputs_set`

5. **FP16 精度**：模型使用 FP16 精度

因此，我们直接使用 rknn_model_zoo 的原始实现，而不是重新实现。

### 推理流程

```
1. Encoder 推理
   - 输入: token embedding + position embedding + mask
   - 输出: encoder output

2. Decoder 增量推理（循环）
   - 输入: decoder embedding + encoder output + masks + key/value 缓存
   - 输出: 预测 token + 更新后的 key/value 缓存
   - 将输出的 key/value 缓存复制到下一次迭代的输入
```

## 常见问题

### Q: setup.sh 报错 "rknn_model_zoo not found"

确保设置了正确的路径：
```bash
RKNN_MODEL_ZOO_PATH=/path/to/rknn_model_zoo ./setup.sh
```

### Q: 编译报错 "librknnrt.so not found"

确保已运行 `./setup.sh` 并且成功复制了库文件。

### Q: 运行时报错 "librknnrt.so: cannot open shared object file"

确保设置了正确的 `LD_LIBRARY_PATH`:
```bash
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
```

### Q: 模型文件不存在

运行 `./setup.sh` 会自动复制模型文件。如果 rknn_model_zoo 中没有模型文件，需要先下载：

```bash
cd /path/to/rknn_model_zoo/examples/lite_transformer/model
./download_model.sh
```

## 参考

- [RKNN Model Zoo](https://github.com/airockchip/rknn_model_zoo)
- [Lite Transformer](https://github.com/airockchip/lite-transformer)
- [RKNN-Toolkit2](https://github.com/airockchip/rknn-toolkit2)

## 许可证

本项目遵循 Apache 2.0 许可证。
