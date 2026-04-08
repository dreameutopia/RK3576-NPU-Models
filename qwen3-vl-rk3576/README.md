# Qwen3-VL RK3576 部署包

本项目提供 Qwen3-VL 多模态模型在 RK3576 平台上的完整部署方案。

> **重要说明**: 本文档所有路径均为相对路径，执行任何命令前请确保已进入本项目根目录：
> ```bash
> cd qwen3-vl-rk3576
> ```

## 目录结构

```
qwen3-vl-rk3576/
├── build.sh                 # 编译脚本
├── CMakeLists.txt           # CMake配置
├── c_export.map             # 符号导出配置
├── setup.sh                 # 环境设置脚本
├── README.md                # 说明文档
├── include/
│   ├── rkllm.h              # RKLLM API头文件
│   └── rknn_api.h           # RKNN API头文件
├── src/
│   ├── image_enc.h          # 图像编码器头文件
│   ├── image_enc.cc         # 图像编码器实现
│   ├── img_encoder.cpp      # 独立图像编码工具
│   └── main.cpp             # 主程序
├── scripts/
│   └── run.sh               # 运行脚本
├── lib/
│   └── aarch64/
│       ├── librkllmrt.so    # RKLLM运行时库 (需复制)
│       └── libomp.so        # OpenMP库 (如需要)
├── 3rdparty/
│   ├── opencv/              # OpenCV库 (需复制)
│   └── librknnrt/           # RKNN运行时库 (需复制)
├── models/
│   ├── qwen3-vl-2b_vision_rk3576.rknn           # Vision模型 (需复制)
│   └── qwen3-vl-2b-instruct_w4a16_g128_rk3576.rkllm  # LLM模型 (需复制)
└── test/
    ├── test1.png            # 测试图片1
    ├── test2.png            # 测试图片2
    └── test3.png            # 测试图片3
```

## 快速开始

### 1. 准备运行时库

使用 `setup.sh` 脚本自动复制依赖库：

```bash
chmod +x setup.sh
./setup.sh -s ../rknn-llm
```

或手动复制：

```bash
# 复制RKLLM运行时库
cp ../rknn-llm/rkllm-runtime/Linux/librkllm_api/aarch64/librkllmrt.so lib/aarch64/

# 复制RKNN运行时库
mkdir -p 3rdparty/librknnrt/Linux/librknn_api/aarch64
cp ../rknn-llm/examples/multimodal_model_demo/deploy/3rdparty/librknnrt/Linux/librknn_api/aarch64/librknnrt.so 3rdparty/librknnrt/Linux/librknn_api/aarch64/
cp -r ../rknn-llm/examples/multimodal_model_demo/deploy/3rdparty/librknnrt/Linux/librknn_api/include 3rdparty/librknnrt/Linux/librknn_api/

# 复制OpenCV库
cp -r ../rknn-llm/examples/multimodal_model_demo/deploy/3rdparty/opencv/opencv-linux-aarch64 3rdparty/opencv/
```

### 2. 复制模型文件

```bash
cp /path/to/qwen3-vl-2b_vision_rk3576.rknn models/
cp /path/to/qwen3-vl-2b-instruct_w4a16_g128_rk3576.rkllm models/
```

### 3. 编译

**在RK3576开发板上直接编译：**
```bash
chmod +x build.sh
./build.sh
```

**交叉编译（在PC上编译）：**
```bash
./build.sh -c ~/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu
```

### 4. 部署到设备

```bash
adb push install/demo_Linux_aarch64 /data

adb shell
cd /data/demo_Linux_aarch64
export LD_LIBRARY_PATH=./lib
chmod +x run.sh
./run.sh
```

## 一键测试推理

### 单图测试

测试test目录下的单张图片：

```bash
cd install/demo_Linux_aarch64
./test_single.sh
```

### 多图并发测试

同时测试test目录下的三张图片（多路并发任务测试）：

```bash
cd install/demo_Linux_aarch64
./test_multi.sh
```

测试脚本会实时打印：
- 推理结果
- 推理用时
- Token速率
- 首Token耗时

## 运行参数

```bash
./run.sh [OPTIONS] [IMAGE_PATH]

选项:
  -v, --vision MODEL    Vision模型路径 (默认: ./models/qwen3-vl-2b_vision_rk3576.rknn)
  -l, --llm MODEL       LLM模型路径 (默认: ./models/qwen3-vl-2b-instruct_w4a16_g128_rk3576.rkllm)
  -t, --tokens NUM      最大生成token数 (默认: 2048)
  -c, --context NUM     最大上下文长度 (默认: 4096)
  -n, --cores NUM       NPU核心数 (RK3576默认: 2)
  -h, --help            显示帮助信息

示例:
  ./run.sh                                    # 使用默认设置
  ./run.sh -t 1024 ./test/test1.png           # 自定义token数和图片
  ./run.sh -v ./models/custom_vision.rknn -l ./models/custom_llm.rkllm
```

## 交互使用

运行后进入交互模式：

```
********************** 可输入以下问题对应序号获取回答 / 或自定义输入 ********************

[0] <image>What is in the image?
[1] <image>这张图片中有什么？

*************************************************************************

user: 0
<image>What is in the image?
robot: The image shows...
```

**特殊命令：**
- 输入 `exit` 退出程序
- 输入 `clear` 清除KV缓存

## 采样参数说明

本程序默认配置了以下采样参数，针对OCR任务优化，避免重复生成：

| 参数 | 值 | 说明 |
|------|-----|------|
| `top_k` | 1 | 保留概率最高的1个token |
| `top_p` | 0.9 | 核采样，保留累计概率90%的token |
| `temperature` | 0.1 | 低温度，输出更确定，适合OCR |
| `repeat_penalty` | 1.5 | 强惩罚重复token，防止生成循环 |
| `frequency_penalty` | 0.5 | 惩罚频繁出现的token |
| `presence_penalty` | 0.5 | 惩罚已出现的token |
| `max_new_tokens` | 256 | 限制最大输出长度 |

> **注意**: 如果需要调整这些参数，请修改 `src/main.cpp` 中的参数设置，然后重新编译。

## 图片分辨率处理

本程序支持任意分辨率的图片输入，处理流程如下：

1. **读取图片**: 使用OpenCV读取图片并转换为RGB格式
2. **扩展为正方形**: 使用`expand2square`函数将非正方形图片扩展为正方形，背景填充灰色(127.5)
3. **缩放到模型尺寸**: 根据Vision模型的输入尺寸要求进行缩放（默认448x448）

> **注意**: Vision模型在导出时指定了固定的输入尺寸（如448x448），程序会自动将图片缩放到该尺寸。Qwen3-VL的patch_size为16，因此输入尺寸应为16的倍数。

## 性能参考 (RK3576)

| 阶段 | 耗时 |
|------|------|
| img-encoder (448x448) | ~1.6s |
| Prefill (len=196) | ~1587ms |
| Decode | ~10.36 tokens/s |
| 内存占用 | ~1.1GB |

## 注意事项

1. **NPU核心数**: RK3576有2个NPU核心，RK3588有3个，请根据平台设置正确的核心数
2. **提频**: 为获得最佳性能，建议运行前执行提频脚本 `../rknn-llm/scripts/fix_freq_rk3576.sh`
3. **内存**: 确保设备有足够的内存（建议≥2GB可用内存）
4. **libomp.so**: 如果遇到 `libomp.so not found` 错误，需要从交叉编译工具链中复制该库

## 模型转换

如需自行转换模型，请参考 `rknn-llm` 仓库的 `examples/multimodal_model_demo/` 目录。

**导出Vision模型：**
```bash
pip install transformers==4.57.0
cd ../rknn-llm/examples/multimodal_model_demo
python export/export_vision.py --path=/path/to/Qwen3-VL --model_name=qwen3-vl --height=448 --width=448
python export/export_vision_rknn.py --path=./onnx/qwen3-vl_vision.onnx --model_name=qwen3-vl --target-platform rk3576
```

**导出LLM模型：**
```bash
cd ../rknn-llm/examples/multimodal_model_demo
python export/export_rkllm.py --path=/path/to/Qwen3-VL --target-platform rk3576 --num_npu_core 2 --quantized_dtype w4a16_g128
```

## 相关链接

- [rknn-llm](https://github.com/airockchip/rknn-llm)
- [rknn-toolkit2](https://github.com/airockchip/rknn-toolkit2)
- [Qwen3-VL](https://huggingface.co/Qwen)
