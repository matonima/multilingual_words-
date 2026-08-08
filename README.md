# Words

A Godot 4.7 learning app for Arabic, Russian, Sanskrit, and Latin. It combines
the multilingual language choice and natural-audio fallback pattern from the
Numbers app with an original generalized version of the Bangla Words living
letter carousel and drag-to-build activity.

## Flow

1. **Welcome to Words** — a moving Ferris wheel of expressive alphabets.
2. Touch a living letter and choose Arabic, Russian, Sanskrit, or Latin.
3. Choose **Alphabets** or **Words**.
4. In Alphabets, spin the carousel and touch a character to hear it.
5. In Words, choose a letter and drag its colorful living pieces onto the
   matching shadows. A held piece repeats its letter sound until release/drop;
   completing the spelling reveals its illustration and speaks the whole word.
   The result card includes a button to hear the pronunciation again.
   Arabic and Russian words are split into individual letters; Arabic harakat
   remain attached to their base letter. Sanskrit vowel signs are separate
   pieces: the sign repeats its -kaar name while held, then joins the consonant
   visually and aloud (for example, क + ा → का).

All supplied Level 1 content is in `scripts/content_data.gd`. The three rare
Sanskrit vowels without example words remain in the alphabet carousel as
sound-first lessons and are omitted from the word-building wheel.

## Run

Open `project.godot` with Godot 4.7 and run the project. The design targets
1280×720 and scales to tablets; buttons support mouse and touch.

## Audio

The app bundles 281 natural neural-voice MP3s and therefore works offline:

- Arabic: native Arabic voice
- Russian: native Russian voice
- Sanskrit letters: natural Hindi Devanagari voice; words follow the supplied
  syllable guides with an Indian English neural voice to preserve final vowels
- Latin words: a British neural voice reads the supplied Classical-style
  syllable guides instead of applying modern Italian pronunciation

If a bundled clip is absent, the app follows the Numbers app pattern and tries
a matching installed system voice, then the supplied phonetic spelling. See
`tools/voicegen/README.md` to regenerate clips. Synthetic pronunciations need
review by fluent speakers before a public release, especially Sanskrit and
reconstructed Classical Latin.

## Versioning

Semantic-version, validation, commit, tag, and push tasks are included. See
`VERSIONING.md` for the one-time Git remote setup and normal release workflow.

## Android and Web exports

Run the **Words: Build Android and Web** editor task, or run
`tools/build_exports.ps1`. It creates an installable debug APK in
`exports/android/` and a website-ready build in `exports/web/`. Exported builds
are intentionally excluded from Git.

## Verification

```powershell
$env:APPDATA="$PWD\.godot_appdata"
D:\godot\Godot_v4.7.1-stable_win64_console.exe --headless --path $PWD --script res://tests/smoke_test.gd
```
