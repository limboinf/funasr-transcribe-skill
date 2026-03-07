---
name: funasr-transcribe
description: 本地音频转录工具，使用阿里 FunASR 模型进行语音识别。支持中文、英文等多种语言，无需 API 费用，完全本地运行。适用于音频文件转写（.wav, .ogg, .mp3 等）、会议记录、语音笔记整理等场景。
---

# FunASR 语音转录

本地、免费、高效的语音识别工具，基于阿里巴巴 FunASR 模型。

## 快速开始

```bash
# 1. 安装 FunASR
bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/install.sh

# 2. 转录音频
bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/transcribe.sh /path/to/audio.ogg
```

## 安装 FunASR

首次使用需要安装 FunASR 环境（虚拟环境 + 依赖）：

```bash
bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/install.sh
```

安装脚本会：
- 创建 Python 虚拟环境 `~/.openclaw/workspace/funasr_env`
- 安装 FunASR、torch、torchaudio、modelscope 等依赖
- 安装完成后，首次转录会自动下载模型文件

**安装时间**：约 5-10 分钟（取决于网络速度）

**系统要求**：
- Python 3.7+
- 约 4GB 磁盘空间（虚拟环境 + 模型）
- 推荐 8GB+ 内存

## 转录音频

安装完成后，转录音频：

```bash
bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/transcribe.sh /path/to/audio.ogg
```

**支持的格式**：`.wav`, `.ogg`, `.mp3`, `.flac`, `.m4a` 等

**输出**：
- 同目录下生成 `<audio_filename>.txt`
- 包含转录文本（带标点）

**性能**：
- CPU 推理：rtf 约 0.05-0.2（1 秒音频约需 0.05-0.2 秒）
- 首次转录需下载模型（约 1-2GB），后续直接使用缓存

## 技术细节

FunASR 使用以下模型组合：
- **ASR 模型**：`damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch`（中文优化）
- **VAD 模型**：`damo/speech_fsmn_vad_zh-cn-16k-common-pytorch`（语音活动检测）
- **标点模型**：`damo/punc_ct-transformer_zh-cn-common-vocab272727-pytorch`（标点恢复）

**语言支持**：
- 中文（普通话 + 方言）
- 英文
- 中英混合

## 常见问题

**Q: 首次转录很慢？**
A: 首次运行会自动下载模型文件（约 1-2GB），后续转录会快很多。

**Q: 可以用 GPU 吗？**
A: 可以。编辑 `scripts/transcribe.py`，将 `device="cpu"` 改为 `device="cuda:0"`，并安装对应的 CUDA 版本依赖。

**Q: 转录准确率如何？**
A: FunASR 在中文场景下表现优异，通常优于 OpenAI Whisper。建议测试后评估效果。
