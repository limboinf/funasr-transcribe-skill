#!/usr/bin/env python3
# SECURITY MANIFEST:
#   Environment variables accessed: none
#   External endpoints called: none directly (FunASR dependencies may download models on first run)
#   Local files read: input audio file
#   Local files written: sibling .txt transcript file

"""FunASR 音频转录脚本"""

import sys
import os
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
INSTALL_SCRIPT = SCRIPT_DIR / "install.sh"

try:
    from funasr import AutoModel
except ImportError:
    print("❌ 错误：未找到 funasr 模块")
    print("")
    print("请先安装 FunASR：")
    print(f"  bash {INSTALL_SCRIPT}")
    sys.exit(1)


def transcribe_audio(audio_path):
    """使用 FunASR 转录音频"""
    print(f"正在处理音频: {audio_path}")
    print("首次运行会自动下载模型，可能需要几分钟...")

    # 加载模型
    model = AutoModel(
        model="damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch",
        vad_model="damo/speech_fsmn_vad_zh-cn-16k-common-pytorch",
        punc_model="damo/punc_ct-transformer_zh-cn-common-vocab272727-pytorch",
        device="cpu",  # 使用 CPU，如果有 GPU 可以改为 "cuda:0"
    )

    # 进行语音识别
    res = model.generate(input=audio_path, batch_size_s=300)

    return res


def main():
    if len(sys.argv) < 2:
        print("用法: python3 transcribe.py <audio_file>")
        sys.exit(1)

    audio_path = sys.argv[1]

    # 检查文件是否存在
    if not os.path.exists(audio_path):
        print(f"❌ 错误：文件不存在: {audio_path}")
        sys.exit(1)

    # 转录
    try:
        result = transcribe_audio(audio_path)
    except Exception as e:
        print(f"❌ 转录失败: {e}")
        print(
            "提示：请检查依赖是否已安装、模型下载所需网络是否可用、音频文件是否有效。"
        )
        sys.exit(1)

    # 输出结果
    text = ""
    if isinstance(result, list) and len(result) > 0:
        text = result[0].get("text", "")

    if not text:
        print("⚠️  未识别到文本")
        sys.exit(0)

    print("\n" + "=" * 50)
    print("转录结果:")
    print("=" * 50)
    print(text)

    # 保存到文件
    output_path = os.path.splitext(audio_path)[0] + ".txt"
    try:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(text)
        print("")
        print(f"✓ 已保存到: {output_path}")
    except Exception as e:
        print(f"\n⚠️  保存文件失败: {e}")


if __name__ == "__main__":
    main()
