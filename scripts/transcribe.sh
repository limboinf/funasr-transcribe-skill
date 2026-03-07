#!/bin/bash
# FunASR 音频转录脚本
# 用途：将音频文件转录为文本

set -e

# 配置
VENV_DIR="$HOME/.openclaw/workspace/funasr_env"
TRANSCRIBE_PY="$HOME/.openclaw/workspace/skills/funasr-transcribe/scripts/transcribe.py"

# 检查参数
if [ $# -lt 1 ]; then
    echo "用法: $0 <audio_file>"
    echo ""
    echo "示例:"
    echo "  $0 /path/to/audio.ogg"
    echo "  $0 recording.wav"
    exit 1
fi

AUDIO_FILE="$1"

# 检查文件是否存在
if [ ! -f "$AUDIO_FILE" ]; then
    echo "❌ 错误：文件不存在: $AUDIO_FILE"
    exit 1
fi

# 检查虚拟环境
if [ ! -d "$VENV_DIR" ]; then
    echo "❌ 错误：FunASR 未安装"
    echo ""
    echo "请先运行安装脚本："
    echo "  bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/install.sh"
    exit 1
fi

# 激活虚拟环境并转录
source "$VENV_DIR/bin/activate"
python3 "$TRANSCRIBE_PY" "$AUDIO_FILE"
