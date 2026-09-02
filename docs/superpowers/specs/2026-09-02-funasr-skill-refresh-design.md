# FunASR Skill Refresh Design

## Goal

Refresh the skill's default speech-recognition pipeline and documentation without losing its local, CPU-friendly behavior. Make installation discoverable through the open Agent Skills CLI.

## Model Choice

Use `FunAudioLLM/SenseVoiceSmall` as the default ASR model and pair it with FunASR's `fsmn-vad`. SenseVoiceSmall is the current official CPU-oriented recommendation for Chinese and mixed-language local transcription. Apply FunASR's rich-transcription postprocessor so language, emotion, event, and text-normalization tags do not leak into the plain-text transcript.

Document `FunAudioLLM/Fun-ASR-Nano-2512` as the newer GPU-oriented flagship rather than making it the default. This preserves the existing CPU-first contract. Remove the legacy Paraformer identifiers from the active pipeline and default-model documentation.

## Portability

Replace the OpenClaw-specific virtual-environment path with a cross-agent cache location. Resolve it in this order:

1. `FUNASR_TRANSCRIBE_VENV` when explicitly set.
2. `$XDG_CACHE_HOME/funasr-transcribe/venv` when `XDG_CACHE_HOME` is set.
3. `$HOME/.cache/funasr-transcribe/venv` otherwise.

Both shell scripts must use the same resolution logic. Existing OpenClaw environments are not deleted or migrated.

## Documentation

Revise `SKILL.md`, `README.md`, and `README.zh-CN.md` to:

- Lead with `npx skills add limboinf/funasr-transcribe-skill` as the installation method.
- Separate skill installation from one-time Python runtime setup.
- Explain the default SenseVoiceSmall model and optional Nano-2512 flagship accurately.
- State Python 3.8+ and the first-run model download requirement.
- Remove OpenClaw-only path assumptions and stale Paraformer model lists.
- Keep the privacy boundary explicit: inference is local, while setup and first use access package/model hosts.

## Implementation Boundaries

- Keep the existing three-script structure and sibling `.txt` output behavior.
- Do not add automatic GPU/model selection, a new CLI parser, diarization, timestamps, batch processing, or model configuration flags.
- Do not download large model weights as part of repository verification.

## Verification

- Parse `SKILL.md` frontmatter and confirm required metadata is present.
- Run shell syntax checks on `install.sh` and `transcribe.sh`.
- Compile `transcribe.py` without importing FunASR.
- Exercise argument and missing-file error paths without installing dependencies.
- Search for stale OpenClaw virtual-environment paths and legacy default model identifiers.
- Review the final diff for consistency between English and Chinese documentation.
