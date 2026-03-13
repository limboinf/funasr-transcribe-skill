#!/bin/bash
# SECURITY MANIFEST:
#   Environment variables accessed: HOME
#   External endpoints called: https://pypi.tuna.tsinghua.edu.cn/simple
#   Local files read: scripts/install.sh
#   Local files written: ~/.openclaw/workspace/funasr_env

set -euo pipefail

VENV_DIR="$HOME/.openclaw/workspace/funasr_env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE_REINSTALL=0

if [[ "${1:-}" == "--force" ]]; then
    FORCE_REINSTALL=1
fi

echo "=========================================="
echo "FunASR 安装脚本"
echo "=========================================="
echo ""

# 检查 Python
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ 错误：未找到 python3"
    echo "请先安装 Python 3.7+"
    exit 1
fi

if ! python3 -m venv --help >/dev/null 2>&1; then
    echo "❌ 错误：当前 Python 不支持 venv"
    echo "请安装 Python venv 模块后重试"
    exit 1
fi

PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "✓ Python 版本: $PYTHON_VERSION"

# 创建虚拟环境
if [ -d "$VENV_DIR" ]; then
    if [ "$FORCE_REINSTALL" -ne 1 ]; then
        echo "⚠️  虚拟环境已存在: $VENV_DIR"
        echo "如需重装，请运行: bash $SCRIPT_DIR/install.sh --force"
        exit 0
    fi

    echo "检测到 --force，正在重建虚拟环境: $VENV_DIR"
    rm -rf "$VENV_DIR"
fi

echo "创建虚拟环境: $VENV_DIR"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# 升级 pip
echo ""
echo "升级 pip..."
pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple

# 安装依赖
echo ""
echo "安装 FunASR 及依赖（这需要几分钟）..."
pip install funasr modelscope huggingface_hub torch torchaudio \
    -i https://pypi.tuna.tsinghua.edu.cn/simple

# 验证安装
echo ""
echo "验证安装..."
python3 -c "from funasr import AutoModel; print('✓ FunASR 安装成功')" || {
    echo "❌ FunASR 安装失败"
    exit 1
}

# 完成
echo ""
echo "=========================================="
echo "✓ 安装完成！"
echo "=========================================="
echo ""
echo "现在可以使用转录功能："
echo "  bash $SCRIPT_DIR/transcribe.sh /path/to/audio.ogg"
echo ""
