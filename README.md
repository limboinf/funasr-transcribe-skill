# FunASR Transcribe Skill

[![skills.sh](https://skills.sh/b/limboinf/funasr-transcribe-skill)](https://skills.sh/limboinf/funasr-transcribe-skill)

Local speech-to-text for Mandarin, Cantonese, English, Japanese, Korean, and mixed-language audio. The default pipeline uses Alibaba FunASR with CPU-friendly SenseVoiceSmall and keeps inference on your machine.

中文说明请见 [README.zh-CN.md](README.zh-CN.md).

## Highlights

- Local inference with no paid transcription API
- CPU-friendly SenseVoiceSmall model with FSMN-VAD
- Language, emotion, and event tags cleaned into readable plain text
- Transcript printed to stdout and written beside the source audio
- Works as an Agent Skill or as standalone scripts

## Install the Skill

Use the open Agent Skills CLI. The package name is plural: `skills`.

```bash
npx skills add limboinf/funasr-transcribe-skill
```

Follow the CLI prompts to choose an agent and project or global scope. See the official [skills CLI documentation](https://skills.sh/docs/cli) for additional options.

Installing the skill makes its instructions and scripts available to your agent. The first transcription also needs a local Python runtime environment; the agent can set it up automatically, or you can run the setup manually from the installed skill directory:

```bash
bash scripts/install.sh
```

To use only the scripts without installing the skill:

```bash
git clone https://github.com/limboinf/funasr-transcribe-skill.git
cd funasr-transcribe-skill
bash scripts/install.sh
```

## Usage

```bash
bash scripts/transcribe.sh /path/to/audio.ogg
```

Common inputs include `.wav`, `.ogg`, `.mp3`, `.flac`, and `.m4a`, subject to the codecs available in the installed audio backend.

The command:

- prints recognized text to stdout
- writes `<audio_filename>.txt` next to the source audio

To rebuild the Python environment:

```bash
bash scripts/install.sh --force
```

## Models

### Default: SenseVoiceSmall

The skill now uses [`FunAudioLLM/SenseVoiceSmall`](https://huggingface.co/FunAudioLLM/SenseVoiceSmall) with `fsmn-vad`. It is optimized for Mandarin, Cantonese, English, Japanese, and Korean, runs efficiently on CPU, and can recognize speech emotion and audio events. FunASR's rich-transcription postprocessor removes those control tags from the saved plain-text transcript.

This replaces the older Paraformer pipeline previously used by the skill.

### Latest flagship: Fun-ASR-Nano-2512

[`FunAudioLLM/Fun-ASR-Nano-2512`](https://huggingface.co/FunAudioLLM/Fun-ASR-Nano-2512) was released in December 2025 and is the newer 800M-parameter flagship for Chinese, English, Japanese, Chinese dialects, and regional accents. The official Python path is GPU-oriented, so it is documented here but is not the default for this CPU-first skill.

See the official [FunASR model overview](https://github.com/modelscope/FunASR#model-zoo) for current model choices.

## Runtime Storage

The setup script stores its virtual environment outside the installed skill so skill updates do not erase dependencies. It resolves the location in this order:

1. `FUNASR_TRANSCRIBE_VENV`
2. `$XDG_CACHE_HOME/funasr-transcribe/venv`
3. `$HOME/.cache/funasr-transcribe/venv`

Example override:

```bash
FUNASR_TRANSCRIBE_VENV=/path/to/venv bash scripts/install.sh
```

## Requirements

- Python 3.8+
- About 4 GB of free disk space for dependencies and cached models
- 8 GB+ RAM recommended for smoother local inference
- Network access during setup and the first model download

## Network, Security, and Privacy

- Audio is processed locally after dependencies and models are available.
- The scripts do not intentionally upload audio to a cloud ASR API.
- Setup downloads Python packages from the configured Tsinghua PyPI mirror.
- First use downloads SenseVoiceSmall and supporting model files from Hugging Face through FunASR.
- Generated transcripts remain local unless you move or upload them.
- No API key or secret is required.

Only install and use the skill if you trust its scripts, package mirror, and upstream model providers.

## Troubleshooting

### Python is missing or too old

Install Python 3.8 or later, then rerun `bash scripts/install.sh`.

### The environment exists but is broken

```bash
bash scripts/install.sh --force
```

### The first transcription is slow

The first run downloads and initializes model files. Later runs reuse the local cache.

### GPU inference is required

Follow the official [Fun-ASR-Nano-2512](https://huggingface.co/FunAudioLLM/Fun-ASR-Nano-2512) setup instead of only changing the CPU device string; GPU installations need compatible PyTorch/CUDA dependencies.

## Development

Run the lightweight checks without downloading model weights:

```bash
python3 -m unittest discover -s tests -v
bash -n scripts/install.sh scripts/transcribe.sh
python3 -m py_compile scripts/transcribe.py tests/test_transcribe.py
```

## License

MIT
