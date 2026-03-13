---
name: funasr-transcribe
description: Use when the user needs local speech-to-text transcription for audio files, especially Chinese or mixed Chinese-English audio, without relying on cloud transcription APIs.
homepage: https://github.com/limboinf/funasr-transcribe-skill
metadata:
  clawdbot:
    emoji: "🎙️"
    requires:
      env: []
    files: ["README.md", "README.zh-CN.md", "LICENSE", "scripts/*"]
---

# FunASR Transcribe

Local speech-to-text for audio files using FunASR. It is best suited to Chinese and mixed Chinese-English audio, runs on the local machine, and does not require a paid transcription API.

## When to Use

- The user wants to transcribe `.wav`, `.ogg`, `.mp3`, `.flac`, or `.m4a` files into text.
- The user prefers local ASR over cloud speech APIs for privacy, cost, or offline-friendly workflows.
- The audio is primarily Chinese, dialect-heavy Chinese, or mixed Chinese-English.
- The user is okay with installing Python dependencies and downloading models on first use.

Do not use this skill when the user explicitly forbids local dependency installation or any network access for dependency/model download.

## Quick Start

```bash
# Install dependencies and create a virtual environment
bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/install.sh

# Transcribe an audio file
bash ~/.openclaw/workspace/skills/funasr-transcribe/scripts/transcribe.sh /path/to/audio.ogg
```

## What It Does

- Creates a Python virtual environment at `~/.openclaw/workspace/funasr_env` by default.
- Installs `funasr`, `torch`, `torchaudio`, `modelscope`, and related dependencies.
- Loads FunASR models locally and writes the transcript to a sibling `.txt` file.
- Prints the transcript to stdout for direct CLI use.

## Models

- ASR: `damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch`
- VAD: `damo/speech_fsmn_vad_zh-cn-16k-common-pytorch`
- Punctuation: `damo/punc_ct-transformer_zh-cn-common-vocab272727-pytorch`

## External Endpoints

| Endpoint | Purpose | Data sent |
| --- | --- | --- |
| `https://pypi.tuna.tsinghua.edu.cn/simple` | Install Python packages during setup | Package names and installer metadata requested by `pip` |
| ModelScope and/or Hugging Face endpoints used by FunASR dependencies | Download model files on first run | Model identifiers and standard HTTP request metadata |

## Security & Privacy

- Audio files are read from the local machine and processed locally by FunASR.
- The transcription flow does not intentionally upload audio content to a cloud ASR API.
- Network access is still required during setup and first-run model download.
- The generated transcript is written to a local `.txt` file next to the source audio unless the write step fails.
- This skill does not require API keys or other secrets by default.

## Model Invocation Note

Autonomous invocation is normal for this skill. If a user asks to transcribe local audio, an agent may install dependencies and run the helper scripts unless the user explicitly opts out of dependency installation or network access.

## Trust Statement

By using this skill, package and model downloads may be fetched from third-party upstream sources such as the configured PyPI mirror and model hosting providers. Only install and use this skill if you trust those upstream sources.

## Troubleshooting

- `python3` not found: install Python 3.7+ and rerun `scripts/install.sh`.
- Install fails in the existing environment: rerun `scripts/install.sh --force` to recreate the virtual environment.
- First transcription is slow: initial model downloads can take several minutes.
- GPU is desired: edit `scripts/transcribe.py` and change `device="cpu"` to a CUDA device after installing the correct CUDA build.
