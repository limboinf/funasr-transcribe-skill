# FunASR 语音转录

本地、免费、高效的语音识别工具，基于阿里巴巴 FunASR 模型。

## 特性

- 🎯 **中文优化**：专为中文场景优化，识别效果优于 OpenAI Whisper
- 💰 **完全免费**：本地运行，无需 API 费用
- 🚀 **高性能**：CPU 推理 rtf 约 0.05-0.2，79秒音频仅需9秒处理
- 🌐 **多语言支持**：中文（普通话+方言）、英文、中英混合
- 🔒 **隐私安全**：所有处理在本地完成，音频不上传云端
- ✨ **标点恢复**：自动添加标点符号，输出可读性强

## 快速开始

### 1. 安装

```bash
bash scripts/install.sh
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

### 2. 转录音频

```bash
bash scripts/transcribe.sh /path/to/audio.ogg
```

**支持的格式**：`.wav`, `.ogg`, `.mp3`, `.flac`, `.m4a` 等

**输出**：同目录下生成 `<audio_filename>.txt`

## 使用示例

### 示例 1：转录 MP3 文件

```bash
bash scripts/transcribe.sh ~/Downloads/买瓜.mp3
```

输出示例：
```
==================================================
转录结果:
==================================================
哥们儿，你这瓜多少钱一斤呢？两块钱一斤。我操这瓜皮子是金子做还是瓜栗子金子做。你看这现在哪有瓜呀？这都是大棚的瓜，你嫌贵我还嫌贵呢，给我挑一个。行，这个怎么样啊？这瓜保熟吗？

✓ 已保存到: ~/Downloads/买瓜.txt
```

### 示例 2：批量处理

```bash
for file in ~/Downloads/*.mp3; do
    bash scripts/transcribe.sh "$file"
done
```

## 技术细节

### 模型组合

FunASR 使用以下模型组合：

- **ASR 模型**：`damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch`
  - 220M 参数，中文优化
  - 支持普通话和多种方言
- **VAD 模型**：`damo/speech_fsmn_vad_zh-cn-16k-common-pytorch`
  - 语音活动检测，自动分割有效语音片段
- **标点模型**：`damo/punc_ct-transformer_zh-cn-common-vocab272727-pytorch`
  - 标点恢复，提升可读性

### 性能指标

- **音频时长**：79 秒
- **转录耗时**：9.6 秒
- **rtf**：0.122（1 秒音频约需 0.12 秒处理）
- **推理设备**：CPU

### 语言支持

- 中文（普通话 + 方言）
- 英文
- 中英混合

## 与 OpenAI Whisper 对比

| 特性 | FunASR | OpenAI Whisper |
|------|---------|---------------|
| **中文识别** | ⭐⭐⭐⭐⭐ 优秀 | ⭐⭐⭐ 良好 |
| **费用** | 完全免费 | API 按量计费 |
| **隐私** | 本地处理 | 云端处理 |
| **安装难度** | 简单（一键脚本） | 需要 API key |
| **标点恢复** | ✅ 自动支持 | ❌ 不支持 |

## 常见问题

### Q: 首次转录很慢？
A: 首次运行会自动下载模型文件（约 1-2GB），后续转录会快很多。

### Q: 可以用 GPU 吗？
A: 可以。编辑 `scripts/transcribe.py`，将 `device="cpu"` 改为 `device="cuda:0"`，并安装对应的 CUDA 版本依赖。

### Q: 转录准确率如何？
A: FunASR 在中文场景下表现优异，通常优于 OpenAI Whisper。建议测试后评估效果。

### Q: 支持哪些音频格式？
A: 支持常见音频格式：`.wav`, `.ogg`, `.mp3`, `.flac`, `.m4a` 等。

### Q: 模型会自动更新吗？
A: 模型文件会缓存到本地，首次下载后重复使用。如需更新模型，删除缓存目录重新转录即可。

## OpenClaw Skill 集成

本项目也可以作为 OpenClaw Skill 使用：

```bash
# 安装
npx clawhub@latest install funasr-transcribe

# 转录（在 OpenClaw 中自动触发）
```

## 许可证

MIT License

## 致谢

- [FunASR](https://github.com/alibaba-damo-academy/FunASR) - 阿里巴巴达摩院开源的语音识别工具包
- [ModelScope](https://modelscope.cn/) - 模型即服务共享社区

## Star History

如果这个项目对你有帮助，请给个 ⭐️
