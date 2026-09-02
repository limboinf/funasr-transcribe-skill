import importlib.util
import sys
import types
import unittest
from pathlib import Path


class FakeAutoModel:
    init_kwargs = None
    generate_kwargs = None

    def __init__(self, **kwargs):
        type(self).init_kwargs = kwargs

    def generate(self, **kwargs):
        type(self).generate_kwargs = kwargs
        return [{"text": "<|zh|><|NEUTRAL|><|Speech|><|withitn|>你好。"}]


funasr = types.ModuleType("funasr")
funasr.AutoModel = FakeAutoModel
funasr_utils = types.ModuleType("funasr.utils")
postprocess_utils = types.ModuleType("funasr.utils.postprocess_utils")
postprocess_utils.rich_transcription_postprocess = lambda text: f"clean:{text}"

sys.modules["funasr"] = funasr
sys.modules["funasr.utils"] = funasr_utils
sys.modules["funasr.utils.postprocess_utils"] = postprocess_utils

SCRIPT_PATH = Path(__file__).resolve().parents[1] / "scripts" / "transcribe.py"
SPEC = importlib.util.spec_from_file_location("transcribe", SCRIPT_PATH)
transcribe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(transcribe)


class TranscribeTest(unittest.TestCase):
    def setUp(self):
        FakeAutoModel.init_kwargs = None
        FakeAutoModel.generate_kwargs = None

    def test_uses_sensevoice_with_vad_and_cpu_defaults(self):
        result = transcribe.transcribe_audio("audio.wav")

        self.assertEqual(
            FakeAutoModel.init_kwargs,
            {
                "model": "FunAudioLLM/SenseVoiceSmall",
                "vad_model": "fsmn-vad",
                "vad_kwargs": {"max_single_segment_time": 30000},
                "device": "cpu",
            },
        )
        self.assertEqual(
            FakeAutoModel.generate_kwargs,
            {
                "input": "audio.wav",
                "cache": {},
                "language": "auto",
                "use_itn": True,
                "batch_size_s": 60,
                "merge_vad": True,
                "merge_length_s": 15,
            },
        )
        self.assertEqual(
            result,
            [{"text": "<|zh|><|NEUTRAL|><|Speech|><|withitn|>你好。"}],
        )

    def test_extract_text_cleans_rich_transcription_tags(self):
        result = [{"text": "<|zh|><|NEUTRAL|><|Speech|><|withitn|>你好。"}]

        self.assertEqual(
            transcribe.extract_text(result),
            "clean:<|zh|><|NEUTRAL|><|Speech|><|withitn|>你好。",
        )

    def test_extract_text_handles_empty_or_malformed_results(self):
        for result in (None, [], [{}], [{"text": None}], "unexpected"):
            with self.subTest(result=result):
                self.assertEqual(transcribe.extract_text(result), "")


if __name__ == "__main__":
    unittest.main()
