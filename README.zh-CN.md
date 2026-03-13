# FunASR Transcribe Skill

基于阿里巴巴 FunASR 的本地音频转文字 skill。它适合中文、英文以及中英混合音频，并尽量把转录过程保留在本地机器上完成。

英文说明请见 [README.md](README.md)。

## 亮点

- 本地语音识别流程，不依赖付费转录 API
- 更适合中文和中英混合音频场景
- 转录结果会输出到标准输出，同时写入同目录 `.txt` 文件
- 适用于会议记录、语音备忘、采访录音等场景

## 安装

```bash
bash scripts/install.sh
```

安装过程会执行以下操作：

- 在 `~/.openclaw/workspace/funasr_env` 创建 Python 虚拟环境
- 安装 `funasr`、`torch`、`torchaudio`、`modelscope` 等依赖
- 模型文件在第一次转录时再下载

如果你想重建环境：

```bash
bash scripts/install.sh --force
```

## 使用方式

```bash
bash scripts/transcribe.sh /path/to/audio.ogg
```

支持的常见格式包括 `.wav`、`.ogg`、`.mp3`、`.flac` 和 `.m4a`。

输出行为：

- 在终端打印识别文本
- 在原音频文件旁边写入 `<audio_filename>.txt`

## Skill 使用场景

当用户提出以下需求时，这个仓库可以作为 skill 使用：

- 转录本地音频文件
- 本地语音转文字
- 希望处理中文或中英混合录音，同时不依赖云端 ASR API

项目主页：`https://github.com/limboinf/funasr-transcribe-skill`

## 模型配置

默认流程使用以下模型：

- ASR：`damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch`
- VAD：`damo/speech_fsmn_vad_zh-cn-16k-common-pytorch`
- 标点恢复：`damo/punc_ct-transformer_zh-cn-common-vocab272727-pytorch`

## 网络、安全与隐私

- 在依赖和模型准备好之后，音频转录主要在本地执行。
- 这些脚本不会主动把音频上传到云端转录 API。
- 安装阶段会从配置的 PyPI 镜像下载 Python 依赖。
- 第一次使用时，FunASR 依赖可能会从上游模型源下载模型文件。
- 生成的转录文本默认保存在本地，除非用户自行移动或上传。

只有在你信任当前依赖镜像和上游模型提供方时，才建议安装和使用这个 skill。

## 环境要求

- Python 3.7+
- 约 4 GB 磁盘空间，用于虚拟环境和模型缓存
- 建议 8 GB 以上内存，以获得更稳定的本地推理体验

## 故障排查

### 找不到 `python3`

请先安装 Python 3.7+，然后重新运行：

```bash
bash scripts/install.sh
```

### 虚拟环境已存在

如需重建，请执行：

```bash
bash scripts/install.sh --force
```

### 首次运行很慢

这通常是因为正在下载和初始化模型。模型缓存完成后，后续运行一般会更快。

### 想用 GPU 推理

编辑 `scripts/transcribe.py`，把 `device="cpu"` 改成合适的 CUDA 设备，并提前安装兼容 CUDA 的依赖版本。

## 开发说明

- `scripts/install.sh` 用于初始化本地运行环境
- `scripts/transcribe.sh` 负责校验输入并启动 Python 入口脚本
- `scripts/transcribe.py` 负责加载模型、执行推理并写出转录结果

## License

MIT
