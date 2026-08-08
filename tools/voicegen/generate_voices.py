"""Generate the bundled natural pronunciation MP3s with Microsoft Edge voices.

The app never needs this tool at runtime: Godot plays the generated MP3s first
and uses an installed system voice only if a clip is missing.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import sys
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
PROJECT = TOOL_DIR.parents[1]
sys.path.insert(0, str(TOOL_DIR / ".packages"))

import edge_tts  # noqa: E402


VOICES = {
    "ar": "ar-SA-ZariyahNeural",
    "ru": "ru-RU-SvetlanaNeural",
    # Edge does not currently expose a Sanskrit-specific voice. The natural
    # Hindi Devanagari voice gives the closest available rendering; a fluent
    # Sanskrit educator should review the clips before publication.
    "sa": "hi-IN-SwaraNeural",
    # A clear Italian voice preserves Latin vowels more consistently than an
    # English voice for these beginner words.
    "la": "it-IT-IsabellaNeural",
}

# Latin has no dedicated neural voice. A British English voice reads carefully
# normalized, continuous prompts so uppercase hints such as "AH" are never
# mistaken for individually spelled letters.
GUIDE_VOICES = {
    "la": "en-GB-SoniaNeural",
}

# Dictionary-audited speech prompts are deliberately separate from the
# child-facing "say it like" labels. Keep these lowercase and word-like: Edge
# voices can spell an all-caps syllable (for example, AH -> A H). Aqua follows
# the requested common English pronunciation; the remaining items preserve the
# beginner Classical-style guides without artificial gaps between syllables.
LATIN_WORD_PROMPTS = [
    "aqua", "boh-noos", "kah-nis", "doh-moos", "eh-go", "fee-lee-oos",
    "gal-lee-na", "hoh-mo", "in-soo-la", "ka-len-dye", "loo-na",
    "mah-ter", "noh-men", "oh-koo-loos", "pah-ter", "kwat-too-or",
    "roh-sa", "sohl", "ter-ra", "wee-ta", "ksoos-toos", "oop-see-lon",
    "zoh-na",
]

RUSSIAN_LETTER_NAMES = [
    "а", "бэ", "вэ", "гэ", "дэ", "е", "ё", "жэ", "зэ", "и",
    "и краткое", "ка", "эль", "эм", "эн", "о", "пэ", "эр", "эс",
    "тэ", "у", "эф", "ха", "цэ", "че", "ша", "ща",
    "твёрдый знак", "ы", "мягкий знак", "э", "ю", "я",
]

ARABIC_LETTER_NAMES = [
    "ألف", "باء", "تاء", "ثاء", "جيم", "حاء", "خاء", "دال", "ذال",
    "راء", "زاي", "سين", "شين", "صاد", "ضاد", "طاء", "ظاء", "عين",
    "غين", "فاء", "قاف", "كاف", "لام", "ميم", "نون", "هاء", "واو", "ياء",
]

LATIN_LETTER_SOUNDS = [
    "a", "be", "ke", "de", "e", "ef", "ge", "ha", "i", "ka", "el",
    "em", "en", "o", "pe", "ku", "er", "es", "te", "u", "iks",
    "upsilon", "zeta",
]

SANSKRIT_VOWEL_SIGN_NAMES = {
    "\u093e": "\u0906\u0915\u093e\u0930",  # aa-kaar
    "\u093f": "\u0907\u0915\u093e\u0930",
    "\u0940": "\u0908\u0915\u093e\u0930",
    "\u0941": "\u0909\u0915\u093e\u0930",
    "\u0942": "\u090a\u0915\u093e\u0930",
    "\u0943": "\u090b\u0915\u093e\u0930",
    "\u0944": "\u0960\u0915\u093e\u0930",
    "\u0947": "\u090f\u0915\u093e\u0930",
    "\u0948": "\u0910\u0915\u093e\u0930",
    "\u094b": "\u0913\u0915\u093e\u0930",
    "\u094c": "\u0914\u0915\u093e\u0930",
    "\u0962": "\u090c\u0915\u093e\u0930",
    "\u0963": "\u0961\u0915\u093e\u0930",
}


def codepoint_key(text: str) -> str:
    return "_".join(f"{ord(character):04x}" for character in text)


def sanskrit_spelling_pieces(word: str) -> list[str]:
    pieces: list[str] = []
    for character in word:
        codepoint = ord(character)
        if codepoint == 0x094D and pieces:
            pieces[-1] += character
        elif character in SANSKRIT_VOWEL_SIGN_NAMES:
            pieces.append(character)
        elif (0x093A <= codepoint <= 0x0957 or 0x0962 <= codepoint <= 0x0963) and pieces:
            pieces[-1] += character
        else:
            pieces.append(character)
    return pieces


def letter_text(code: str, index: int, entry: dict) -> str:
    if code == "ar":
        return ARABIC_LETTER_NAMES[index]
    if code == "ru":
        return RUSSIAN_LETTER_NAMES[index]
    if code == "la":
        return LATIN_LETTER_SOUNDS[index]
    return str(entry["letter"])


def word_text(code: str, index: int, entry: dict) -> tuple[str, str]:
    word = str(entry["word"])
    if code == "sa":
        # A native Indic voice reading Devanagari handles Sanskrit clusters
        # such as ग्न in अग्नि. The previous English "ag nee" prompt could
        # insert a /dʒ/ sound and produce "ajinee".
        return word, VOICES["sa"]
    if code == "la":
        return LATIN_WORD_PROMPTS[index], GUIDE_VOICES["la"]
    return word, VOICES[code]


async def render_one(text: str, voice: str, destination: Path, semaphore: asyncio.Semaphore) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    async with semaphore:
        last_error: Exception | None = None
        for attempt in range(4):
            try:
                speech = edge_tts.Communicate(
                    text=text,
                    voice=voice,
                    rate="-8%",
                    volume="+0%",
                    pitch="+3Hz",
                )
                await speech.save(str(destination))
                if destination.stat().st_size < 500:
                    raise RuntimeError("voice service returned an empty clip")
                print(f"created {destination.relative_to(PROJECT)}")
                return
            except Exception as exc:  # network retries are expected in a batch
                last_error = exc
                if destination.exists():
                    destination.unlink()
                await asyncio.sleep(1.5 * (attempt + 1))
        raise RuntimeError(f"Failed {destination}: {last_error}")


async def generate(overwrite: bool, only_language: str | None) -> None:
    manifest_path = PROJECT / "data" / "voice_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    semaphore = asyncio.Semaphore(5)
    jobs = []
    for code, payload in manifest["languages"].items():
        if only_language and code != only_language:
            continue
        voice = VOICES[code]
        for ordinal, entry in enumerate(payload["entries"], start=1):
            letter_path = PROJECT / "assets" / "audio" / "alphabets" / code / f"{ordinal:02d}.mp3"
            if overwrite or not letter_path.exists() or letter_path.stat().st_size < 500:
                jobs.append(render_one(letter_text(code, ordinal - 1, entry), voice, letter_path, semaphore))
            word = str(entry.get("word", "")).strip()
            if word:
                word_path = PROJECT / "assets" / "audio" / "words" / code / f"{ordinal:02d}.mp3"
                if overwrite or not word_path.exists() or word_path.stat().st_size < 500:
                    spoken_word, word_voice = word_text(code, ordinal - 1, entry)
                    jobs.append(render_one(spoken_word, word_voice, word_path, semaphore))

    # Sanskrit spelling exposes vowel signs as their own draggable pieces. Give
    # each sign its traditional -kaar name, and each consonant/sign combination
    # a native Devanagari clip so a consonant plus aa-kaar is heard as "kaa".
    if only_language in (None, "sa"):
        component_root = PROJECT / "assets" / "audio" / "pieces" / "sa"
        used_signs: set[str] = set()
        combined_syllables: set[str] = set()
        for entry in manifest["languages"]["sa"]["entries"]:
            pieces = sanskrit_spelling_pieces(str(entry.get("word", "")))
            for index, piece in enumerate(pieces):
                if piece not in SANSKRIT_VOWEL_SIGN_NAMES:
                    continue
                used_signs.add(piece)
                if index > 0 and not pieces[index - 1].endswith("\u094d"):
                    combined_syllables.add(pieces[index - 1] + piece)
        for sign in used_signs:
            destination = component_root / f"matra_{codepoint_key(sign)}.mp3"
            if overwrite or not destination.exists() or destination.stat().st_size < 500:
                jobs.append(render_one(SANSKRIT_VOWEL_SIGN_NAMES[sign], VOICES["sa"], destination, semaphore))
        for syllable in combined_syllables:
            destination = component_root / f"combo_{codepoint_key(syllable)}.mp3"
            if overwrite or not destination.exists() or destination.stat().st_size < 500:
                jobs.append(render_one(syllable, VOICES["sa"], destination, semaphore))
    if not jobs:
        print("All requested clips already exist.")
        return
    results = await asyncio.gather(*jobs, return_exceptions=True)
    failures = [result for result in results if isinstance(result, Exception)]
    if failures:
        for failure in failures:
            print(f"ERROR: {failure}", file=sys.stderr)
        raise SystemExit(f"{len(failures)} clip(s) failed")
    print(f"Generated {len(jobs)} natural voice clips.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--language", choices=sorted(VOICES))
    args = parser.parse_args()
    asyncio.run(generate(args.overwrite, args.language))


if __name__ == "__main__":
    main()
