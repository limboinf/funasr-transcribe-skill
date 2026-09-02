# FunASR Skill Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the CPU-first transcription pipeline to SenseVoiceSmall, make runtime storage agent-neutral, and document installation through `npx skills`.

**Architecture:** Keep the existing shell-wrapper/Python-entrypoint structure. Both shell scripts resolve one portable virtual-environment path; the Python entrypoint uses the official SenseVoiceSmall + FSMN-VAD pipeline and converts rich transcription output to plain text.

**Tech Stack:** Bash, Python 3.8+, FunASR, PyTorch, ModelScope/Hugging Face, Markdown, Vercel Labs `skills` CLI.

## Global Constraints

- Default ASR model: `FunAudioLLM/SenseVoiceSmall` on CPU.
- Optional flagship documented but not selected automatically: `FunAudioLLM/Fun-ASR-Nano-2512` on GPU.
- Virtual environment precedence: `FUNASR_TRANSCRIBE_VENV`, then `$XDG_CACHE_HOME/funasr-transcribe/venv`, then `$HOME/.cache/funasr-transcribe/venv`.
- Preserve stdout output and sibling `<audio_filename>.txt` output.
- Do not add GPU auto-selection, diarization, timestamps, batch processing, or a model-selection CLI.
- Do not download model weights during verification.

---

### Task 1: Upgrade and verify the runtime pipeline

**Files:**
- Modify: `scripts/install.sh`
- Modify: `scripts/transcribe.sh`
- Modify: `scripts/transcribe.py`
- Create: `tests/test_transcribe.py`

**Interfaces:**
- Consumes: one audio path passed to `scripts/transcribe.sh`.
- Produces: `transcribe_audio(audio_path: str) -> list`, `extract_text(result: object) -> str`, terminal text, and a sibling `.txt` file.

- [ ] **Step 1: Add focused tests for SenseVoice model configuration and rich-text cleanup**

Create `tests/test_transcribe.py` with fake `funasr` modules inserted into `sys.modules`, import `scripts/transcribe.py`, and assert that `AutoModel` receives `model="FunAudioLLM/SenseVoiceSmall"`, `vad_model="fsmn-vad"`, `device="cpu"`, and that `extract_text` calls `rich_transcription_postprocess`. Include empty and malformed result cases returning `""`.

- [ ] **Step 2: Run the tests and confirm the legacy implementation fails**

Run: `python3 -m unittest discover -s tests -v`

Expected: FAIL because the legacy Paraformer identifiers are passed and `extract_text` does not exist.

- [ ] **Step 3: Implement the official SenseVoiceSmall inference path**

In `scripts/transcribe.py`:

- Import `rich_transcription_postprocess` from `funasr.utils.postprocess_utils` with the existing actionable missing-dependency error.
- Construct `AutoModel` with `model="FunAudioLLM/SenseVoiceSmall"`, `vad_model="fsmn-vad"`, `vad_kwargs={"max_single_segment_time": 30000}`, and `device="cpu"`.
- Generate with `cache={}`, `language="auto"`, `use_itn=True`, `batch_size_s=60`, `merge_vad=True`, and `merge_length_s=15`.
- Add `extract_text(result)` that accepts only a non-empty list whose first item is a dictionary containing a string `text`, then returns `rich_transcription_postprocess(text)`.
- Keep output and sibling file behavior unchanged.

- [ ] **Step 4: Make virtual-environment storage portable**

In both shell scripts, replace the OpenClaw path with:

```bash
VENV_DIR="${FUNASR_TRANSCRIBE_VENV:-${XDG_CACHE_HOME:-$HOME/.cache}/funasr-transcribe/venv}"
```

Update security manifests and user-facing output. In `install.sh`, require Python 3.8+ with an explicit version check before creating the environment and create the parent directory using `mkdir -p "$(dirname "$VENV_DIR")"`.

- [ ] **Step 5: Run targeted runtime verification**

Run:

```bash
python3 -m unittest discover -s tests -v
bash -n scripts/install.sh scripts/transcribe.sh
python3 -m py_compile scripts/transcribe.py tests/test_transcribe.py
bash scripts/transcribe.sh /definitely/missing.wav
```

Expected: unit tests pass; syntax/compile checks exit 0; missing-file check exits 1 with a clear message.

- [ ] **Step 6: Commit the runtime upgrade**

```bash
git add scripts/install.sh scripts/transcribe.sh scripts/transcribe.py tests/test_transcribe.py
git commit -m "feat: upgrade local transcription to SenseVoice"
```

### Task 2: Refresh skill metadata and bilingual documentation

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`

**Interfaces:**
- Consumes: repository URL `limboinf/funasr-transcribe-skill` and the runtime contract from Task 1.
- Produces: agent discovery metadata and accurate English/Chinese setup, usage, model, privacy, and troubleshooting guidance.

- [ ] **Step 1: Rewrite skill metadata and operating instructions**

Change the frontmatter description to third-person discovery copy covering local Chinese, Cantonese, and mixed-language transcription. Update quick start commands to be relative to the installed skill directory rather than OpenClaw-specific absolute paths. Replace the model list with SenseVoiceSmall + FSMN-VAD and identify Nano-2512 as the optional GPU flagship.

- [ ] **Step 2: Add `npx skills` installation to both READMEs**

Lead each installation section with:

```bash
npx skills add limboinf/funasr-transcribe-skill
```

State that the package/CLI name is plural `skills`. Separate skill installation from running `bash scripts/install.sh` inside the installed skill directory.

- [ ] **Step 3: Synchronize model, requirements, storage, and privacy copy**

In both READMEs:

- Set Python floor to 3.8.
- Describe the portable cache path and `FUNASR_TRANSCRIBE_VENV` override.
- Document SenseVoiceSmall's Mandarin, Cantonese, English, Japanese, and Korean focus plus rich-transcription cleanup.
- Link official SenseVoiceSmall, Fun-ASR-Nano-2512, FunASR, and skills.sh documentation.
- Explain that Nano-2512 is newer but not default because its Python path is GPU-oriented.
- Keep local-inference and package/model download network boundaries explicit.

- [ ] **Step 4: Validate documentation and stale-reference removal**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
import yaml
text = Path("SKILL.md").read_text()
frontmatter = text.split("---", 2)[1]
data = yaml.safe_load(frontmatter)
assert data["name"] == "funasr-transcribe"
assert data["description"]
PY
rg -n '\.openclaw|speech_paraformer-large|Python 3\.7' SKILL.md README.md README.zh-CN.md scripts || true
rg -n 'npx skills add limboinf/funasr-transcribe-skill|FunAudioLLM/SenseVoiceSmall|Fun-ASR-Nano-2512' SKILL.md README.md README.zh-CN.md
git diff --check
```

Expected: metadata assertions pass; stale-reference search has no output; required new references appear in all intended documents; diff check exits 0.

- [ ] **Step 5: Commit the documentation refresh**

```bash
git add SKILL.md README.md README.zh-CN.md
git commit -m "docs: refresh FunASR skill installation and models"
```

### Task 3: Final integrated verification

**Files:**
- Verify only: all changed files.

**Interfaces:**
- Consumes: Tasks 1 and 2.
- Produces: evidence that runtime tests, syntax checks, metadata, and documentation agree.

- [ ] **Step 1: Run the complete lightweight verification suite**

Run:

```bash
python3 -m unittest discover -s tests -v
bash -n scripts/install.sh scripts/transcribe.sh
python3 -m py_compile scripts/transcribe.py tests/test_transcribe.py
git diff HEAD~2 --check
git status --short
```

Expected: tests and checks pass. Status contains no unintended generated files; model weights were not downloaded.

- [ ] **Step 2: Review commits and final diff against the design**

Run: `git log -3 --oneline && git diff HEAD~2..HEAD --stat && git diff HEAD~2..HEAD`

Expected: one runtime commit and one documentation commit after the design commit; changes stay within the approved files and behavior.
