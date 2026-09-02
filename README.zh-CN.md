# FunASR Transcribe Skill

[![skills.sh](https://skills.sh/b/limboinf/funasr-transcribe-skill)](https://skills.sh/limboinf/funasr-transcribe-skill)

面向普通话、粤语、英语、日语、韩语及混合语言音频的本地语音转文字 Skill。默认使用阿里巴巴 FunASR 与适合 CPU 推理的 SenseVoiceSmall，音频识别过程保留在本机。

英文说明请见 [README.md](README.md)。

## 亮点

- 本地推理，不依赖付费转录 API
- 默认使用适合 CPU 的 SenseVoiceSmall 与 FSMN-VAD
- 自动清理语言、情绪和音频事件控制标签，输出易读纯文本
- 在终端打印结果，同时在音频旁写入 `.txt` 文件
- 既可作为 Agent Skill 使用，也可单独运行脚本

## 安装 Skill

使用开放的 Agent Skills CLI。注意包名是复数 `skills`：

```bash
npx skills add limboinf/funasr-transcribe-skill
```

根据 CLI 提示选择 Agent，以及项目级或全局安装范围。更多选项请参考官方 [skills CLI 文档](https://skills.sh/docs/cli)。

上述命令会把 Skill 指令和脚本安装给 Agent。第一次转录前还需要准备本地 Python 运行环境；可以让 Agent 自动完成，也可以进入已安装的 Skill 目录手动执行：

```bash
bash scripts/install.sh
```

如果只想使用脚本，不安装 Skill：

```bash
git clone https://github.com/limboinf/funasr-transcribe-skill.git
cd funasr-transcribe-skill
bash scripts/install.sh
```

## 使用方式

```bash
bash scripts/transcribe.sh /path/to/audio.ogg
```

常见输入格式包括 `.wav`、`.ogg`、`.mp3`、`.flac` 和 `.m4a`；实际可解码格式取决于已安装的音频后端及编解码器。

命令会：

- 在终端打印识别文本
- 在源音频旁写入 `<audio_filename>.txt`

如需重建 Python 环境：

```bash
bash scripts/install.sh --force
```

## 模型

### 默认模型：SenseVoiceSmall

Skill 现在使用 [`FunAudioLLM/SenseVoiceSmall`](https://huggingface.co/FunAudioLLM/SenseVoiceSmall) 和 `fsmn-vad`。该模型重点支持普通话、粤语、英语、日语和韩语，CPU 推理效率较高，还能识别语音情绪及音频事件。脚本会通过 FunASR 的富文本转录后处理器清理控制标签，再保存纯文本结果。

它取代了这个 Skill 之前使用的旧版 Paraformer 流程。

### 最新旗舰：Fun-ASR-Nano-2512

[`FunAudioLLM/Fun-ASR-Nano-2512`](https://huggingface.co/FunAudioLLM/Fun-ASR-Nano-2512) 发布于 2025 年 12 月，是更新的 8 亿参数旗舰模型，支持中文、英语、日语、多种中文方言和地区口音。官方 Python 使用路径更偏向 GPU，因此这里会介绍它，但不会将它设为这个 CPU 优先 Skill 的默认模型。

当前模型选择可查看官方 [FunASR 模型总览](https://github.com/modelscope/FunASR#model-zoo)。

## 运行环境存储位置

安装脚本会把虚拟环境保存在 Skill 目录之外，避免更新 Skill 时删除依赖。路径按以下优先级确定：

1. `FUNASR_TRANSCRIBE_VENV`
2. `$XDG_CACHE_HOME/funasr-transcribe/venv`
3. `$HOME/.cache/funasr-transcribe/venv`

自定义示例：

```bash
FUNASR_TRANSCRIBE_VENV=/path/to/venv bash scripts/install.sh
```

## 环境要求

- Python 3.8+
- 约 4 GB 可用磁盘空间，用于依赖和模型缓存
- 建议 8 GB 以上内存，以获得更平稳的本地推理体验
- 安装及首次下载模型时需要网络连接

## 网络、安全与隐私

- 依赖和模型准备好之后，音频在本机处理。
- 脚本不会主动把音频上传到云端 ASR API。
- 安装阶段从已配置的清华 PyPI 镜像下载 Python 包。
- 第一次使用时，FunASR 会从 Hugging Face 下载 SenseVoiceSmall 及配套模型文件。
- 生成的转录文件保留在本机，除非你自行移动或上传。
- 默认不需要 API Key 或其他密钥。

只有在信任本仓库脚本、包镜像和上游模型提供方时，才建议安装和使用。

## 故障排查

### Python 缺失或版本过低

请安装 Python 3.8 或更高版本，然后重新执行 `bash scripts/install.sh`。

### 虚拟环境存在但已损坏

```bash
bash scripts/install.sh --force
```

### 第一次转录很慢

首次运行需要下载并初始化模型；后续运行会复用本地缓存。

### 需要 GPU 推理

请按照官方 [Fun-ASR-Nano-2512](https://huggingface.co/FunAudioLLM/Fun-ASR-Nano-2512) 指引安装，不建议只修改 CPU 设备字符串；GPU 环境还需要匹配的 PyTorch 与 CUDA 依赖。

## 开发验证

以下轻量检查不会下载模型权重：

```bash
python3 -m unittest discover -s tests -v
bash -n scripts/install.sh scripts/transcribe.sh
python3 -m py_compile scripts/transcribe.py tests/test_transcribe.py
```

## License

MIT
