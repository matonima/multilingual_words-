# Natural voice generation

`generate_voices.py` creates the bundled MP3 pronunciation library used by the
Godot app. Arabic and Russian use native neural voices. Sanskrit letters use a
natural Hindi Devanagari voice, while Sanskrit words use the educator-supplied
syllable guides with an Indian English voice to avoid Hindi schwa deletion.
Latin words likewise use the supplied Classical-style syllable guides rather
than modern Italian spelling rules.

Run the manifest export after changing content, then regenerate missing clips:

```powershell
$env:APPDATA="$PWD\.godot_appdata"
D:\godot\Godot_v4.7.1-stable_win64_console.exe --headless --path $PWD --script res://tools/export_voice_manifest.gd
& "C:\path\to\python.exe" tools\voicegen\generate_voices.py
```

Godot plays these MP3s first. If a file is unavailable, `audio_service.gd`
selects a matching device voice and then falls back to phonetic text. Synthetic
pronunciations must be reviewed by fluent speakers before a public release,
especially Sanskrit and reconstructed Classical Latin.
