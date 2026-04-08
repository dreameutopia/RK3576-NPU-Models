# Zipformer RK3576 语音识别部署包


注意：该仓库未经验证可用，有编译链接等问题待验证

基于k2-zipformer的中英文语音识别(ASR)在RK3576平台的完整部署方案。

## 目录结构

```
zipformer-rk3576/
├── build.sh              # 编译脚本（在RK3576板上运行）
├── setup.sh              # 依赖库设置脚本（在开发机上运行）
├── prepare_models.sh     # 模型下载和转换脚本
├── clean.sh              # 清理脚本
├── run.sh                # 运行脚本
├── CMakeLists.txt        # CMake配置
├── src/                  # 源代码
│   ├── main.cc           # 主程序入口
│   ├── zipformer.h/cc    # Zipformer推理实现
│   └── process.h/cc      # 预处理实现
├── scripts/              # 测试脚本
│   ├── test_single.sh    # 单音频测试
│   └── test_multi.sh     # 多音频/多路并发测试
├── python/               # Python工具
│   └── convert.py        # ONNX转RKNN脚本
├── test/                 # 测试音频目录
├── 3rdparty/             # 依赖库（setup.sh生成）
│   ├── rknpu2/           # RKNN运行时
│   ├── kaldi_native_fbank/ # 音频特征提取
│   ├── fftw/             # FFT库
│   ├── libsndfile/       # 音频文件读写
│   ├── timer/            # 计时工具
│   └── stb_image/        # 图像处理
├── utils/                # 工具函数（setup.sh生成）
├── model/                # RKNN模型
└── install/              # 编译输出
```

## 使用流程

### 步骤 1: 在开发机上准备环境

```bash
# 安装rknn-toolkit2
conda create -n rknn3 python=3.10 -y
conda activate rknn3
pip install rknn-toolkit2 setuptools==69.0.0 onnx==1.15.0 numpy==1.26.4
```

### 步骤 2: 准备模型

```bash
conda activate rknn3
./prepare_models.sh
```

### 步骤 3: 设置依赖库（在开发机上运行）

```bash
# 指定rknn_model_zoo路径
./setup.sh /path/to/rknn_model_zoo

# 例如：
./setup.sh ../rknn_model_zoo
```

### 步骤 4: 复制到RK3576板

```bash
# 将整个项目复制到开发板
scp -r zipformer-rk3576 root@192.168.x.x:/www/wwwroot/
```

### 步骤 5: 在RK3576板上编译

```bash
cd /www/wwwroot/zipformer-rk3576
./build.sh
```

### 步骤 6: 测试

```bash
# 单音频测试
./scripts/test_single.sh -i model/test.wav

# 多音频测试
./scripts/test_multi.sh

# 并发测试
./scripts/test_multi.sh -m concurrent -n 4
```

## 测试脚本使用

### 单音频测试

```bash
# 测试WAV文件
./scripts/test_single.sh -i model/test.wav

# 测试MP3文件（自动转换）
./scripts/test_single.sh -i test/test.mp3
```

### 多音频测试

```bash
# 顺序测试
./scripts/test_multi.sh

# 并发测试（4路并行）
./scripts/test_multi.sh -m concurrent -n 4

# 指定音频目录
./scripts/test_multi.sh -d test/
```

## 技术参数

| 参数 | 值 |
|------|-----|
| 采样率 | 16000 Hz |
| 特征维度 | 80 (Mel Fbank) |
| 词汇表大小 | 6257 |
| 编码器输出维度 | 512 |
| 支持语言 | 中文、英文 |

## 预期输出

```
==========================================
Zipformer RK3576 Single Audio Test
==========================================
model input num: 1, output num: 5
...
Recognized text: 对我做了介绍那么我想说的是大家如果对我的研究感兴趣呢
Real Time Factor (RTF): 2.500 / 10.000 = 0.250
==========================================
```

## 常见问题

### Q: setup.sh报错找不到rknn_model_zoo

确保指定正确的路径：
```bash
./setup.sh /path/to/rknn_model_zoo
```

### Q: 编译报错找不到3rdparty

需要先在开发机上运行setup.sh，然后复制整个项目到开发板。

### Q: 音频格式不支持

脚本会自动使用ffmpeg转换非WAV格式。安装ffmpeg：
```bash
sudo apt install ffmpeg
```

## 性能参考

| 平台 | 音频长度 | 推理时间 | RTF |
|------|----------|----------|-----|
| RK3576 | 10s | ~2.5s | ~0.25 |

## 参考资料

- [k2-zipformer 项目](https://github.com/k2-fsa/k2)
- [RKNN-Toolkit2 文档](https://github.com/rockchip-linux/rknn-toolkit2)
- [RKNN Model Zoo](https://github.com/rockchip-linux/rknn-model-zoo)

## 许可证

本项目遵循 Apache 2.0 许可证。
