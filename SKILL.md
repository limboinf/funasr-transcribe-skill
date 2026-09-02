---
name: funasr-transcribe
description: Transcribes local audio to text with FunASR and CPU-friendly SenseVoiceSmall. Use for Mandarin, Cantonese, English, Japanese, Korean, or mixed-language recordings when local processing is preferred over cloud ASR APIs.
homepage: https://github.com/limboinf/funasr-transcribe-skill
compatibility: Requires Python 3.8+, network access during setup and first model download, and about 4 GB of free disk space.
metadata:
  clawdbot:
    emoji: "🎙️"
    requires:
      env: []
    files: ["README.md", "README.zh-CN.md", "LICENSE", "scripts/*"]
---

# FunASR Transcribe

Transcribe audio locally with FunASR, using SenseVoiceSmall on CPU by default. The workflow prints plain text and writes a sibling `.txt` file without sending audio to a cloud transcription API.

## When to Use

- The user wants to transcribe `.wav`, `.ogg`, `.mp3`, `.flac`, or `.m4a` files into text.
- The recording contains Mandarin, Cantonese, English, Japanese, Korean, or mixed speech.
- The user prefers local inference for privacy, cost, or offline reuse after setup.
- The user is okay with installing Python dependencies and downloading models on first use.

Do not use this skill when the user forbids local dependency installation or all network access and the dependencies/models are not already cached.

## Workflow

Resolve the commands below relative to this skill's directory.

1. If the runtime environment does not exist, explain that setup downloads Python packages and model files, then run:

```bash
bash scripts/install.sh
```

2. Transcribe the requested audio file:

```bash
bash scripts/transcribe.sh /path/to/audio.ogg
```

3. Return the transcript and the output path to the user. The script writes `<audio_filename>.txt` beside the source audio.

To rebuild a broken or outdated runtime environment:

```bash
bash scripts/install.sh --force
```

## Runtime Storage

The virtual environment is selected in this order:

1. `FUNASR_TRANSCRIBE_VENV`
2. `$XDG_CACHE_HOME/funasr-transcribe/venv`
3. `$HOME/.cache/funasr-transcribe/venv`

## Models

- Default ASR: [`FunAudioLLM/SenseVoiceSmall`](https://huggingface.co/FunAudioLLM/SenseVoiceSmall)
- VAD: `fsmn-vad`
- Rich output is normalized to plain text with FunASR's `rich_transcription_postprocess`.

[`FunAudioLLM/Fun-ASR-Nano-2512`](https://huggingface.co/FunAudioLLM/Fun-ASR-Nano-2512) is the newer GPU-oriented flagship. Do not switch to it automatically: this skill intentionally keeps a CPU-first default.

## External Endpoints

| Endpoint | Purpose | Data sent |
| --- | --- | --- |
| `https://pypi.tuna.tsinghua.edu.cn/simple` | Install Python packages during setup | Package names and installer metadata requested by `pip` |
| Hugging Face endpoints used by FunASR | Download SenseVoiceSmall and related model files on first run | Model identifiers and standard HTTP request metadata |

## Security & Privacy

- Audio files are read from the local machine and processed locally by FunASR.
- The transcription flow does not intentionally upload audio content to a cloud ASR API.
- Network access is still required during setup and first-run model download.
- The generated transcript is written to a local `.txt` file next to the source audio unless the write step fails.
- This skill does not require API keys or other secrets by default.

## Trust Statement

By using this skill, package and model downloads may be fetched from third-party upstream sources such as the configured PyPI mirror and model hosting providers. Only install and use this skill if you trust those upstream sources.

## Troubleshooting

- `python3` not found or too old: install Python 3.8+ and rerun `scripts/install.sh`.
- Install fails in the existing environment: rerun `scripts/install.sh --force` to recreate the virtual environment.
- First transcription is slow: initial model downloads can take several minutes.
- Need the latest GPU model: use the official Fun-ASR-Nano-2512 instructions instead of silently changing this skill's CPU pipeline.
