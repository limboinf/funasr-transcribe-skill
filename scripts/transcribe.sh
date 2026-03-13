#!/bin/bash
# SECURITY MANIFEST:
#   Environment variables accessed: HOME
#   External endpoints called: none directly (Python process may trigger model download on first run)
#   Local files read: input audio file, scripts/transcribe.py, ~/.openclaw/workspace/funasr_env
#   Local files written: sibling .txt file created by scripts/transcribe.py

set -euo pipefail

VENV_DIR="$HOME/.openclaw/workspace/funasr_env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSCRIBE_PY="$SCRIPT_DIR/transcribe.py"

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
    echo "  bash $SCRIPT_DIR/install.sh"
    exit 1
fi

if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo "❌ 错误：虚拟环境不完整: $VENV_DIR"
    echo "请重新运行安装脚本："
    echo "  bash $SCRIPT_DIR/install.sh --force"
    exit 1
fi

if [ ! -f "$TRANSCRIBE_PY" ]; then
    echo "❌ 错误：未找到转录脚本: $TRANSCRIBE_PY"
    exit 1
fi

# 激活虚拟环境并转录
source "$VENV_DIR/bin/activate"
python3 "$TRANSCRIBE_PY" "$AUDIO_FILE"
