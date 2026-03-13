# FunASR Transcribe Skill

Local speech-to-text for audio files using Alibaba FunASR. This skill is designed mainly for Chinese and mixed Chinese-English audio, while keeping the transcription step on the local machine.

中文说明请见 [README.zh-CN.md](README.zh-CN.md).

## Highlights

- Local ASR workflow with no paid transcription API requirement
- Good fit for Chinese and mixed Chinese-English audio
- Writes the transcript to a sibling `.txt` file and prints it to stdout
- Suitable for meeting notes, voice memos, and recorded interviews

## Install

```bash
bash scripts/install.sh
```

What installation does:

- Creates a Python virtual environment at `~/.openclaw/workspace/funasr_env`
- Installs `funasr`, `torch`, `torchaudio`, `modelscope`, and related dependencies
- Leaves model download to the first transcription run

If you want to recreate the environment:

```bash
bash scripts/install.sh --force
```

## Usage

```bash
bash scripts/transcribe.sh /path/to/audio.ogg
```

Supported formats include `.wav`, `.ogg`, `.mp3`, `.flac`, and `.m4a`.

Output behavior:

- Prints the recognized text to stdout
- Writes `<audio_filename>.txt` next to the source audio file

## Skill Usage

This repository can be packaged as a skill and used when a user asks to:

- transcribe local audio files
- convert speech to text locally
- process Chinese or mixed Chinese-English recordings without cloud ASR APIs

Homepage: `https://github.com/limboinf/funasr-transcribe-skill`

## Models

The default pipeline uses:

- ASR: `damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch`
- VAD: `damo/speech_fsmn_vad_zh-cn-16k-common-pytorch`
- Punctuation: `damo/punc_ct-transformer_zh-cn-common-vocab272727-pytorch`

## Network, Security, and Privacy

- Audio transcription runs locally after dependencies and models are available.
- The scripts do not intentionally upload audio to a cloud transcription API.
- Installation downloads Python packages from the configured PyPI mirror.
- First use may download model files from upstream model hosts used by FunASR dependencies.
- Generated transcript files stay on the local machine unless the user moves them elsewhere.

Only install and use this skill if you trust the configured package mirror and the upstream model providers.

## Requirements

- Python 3.7+
- Roughly 4 GB of disk space for the virtual environment and cached models
- Recommended 8 GB+ RAM for smoother local inference

## Troubleshooting

### `python3` not found

Install Python 3.7+ and rerun:

```bash
bash scripts/install.sh
```

### Virtual environment already exists

Recreate it with:

```bash
bash scripts/install.sh --force
```

### First run is slow

That is usually model download and initialization. Later runs should be faster once the models are cached.

### Want GPU inference

Edit `scripts/transcribe.py` and change `device="cpu"` to the appropriate CUDA device after installing CUDA-compatible dependencies.

## Development Notes

- `scripts/install.sh` bootstraps the local environment
- `scripts/transcribe.sh` validates inputs and launches the Python entrypoint
- `scripts/transcribe.py` loads the models, performs inference, and writes the transcript

## License

MIT
