class_name AudioService
extends Node

signal playback_started(path: String)
signal playback_failed(path: String)

var player: AudioStreamPlayer
var request_serial := 0


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.name = "NaturalVoice"
	player.bus = "Master"
	# A small boost keeps short isolated phonemes audible on tablet speakers.
	player.volume_db = 4.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)


func play(path: String, native_text: String, language_code: String, phonetic_fallback := "", loop := false) -> void:
	stop()
	request_serial += 1
	var serial := request_serial
	if not path.is_empty() and ResourceLoader.exists(path):
		var recording := ResourceLoader.load(path, "AudioStream") as AudioStream
		if recording != null:
			# Duplicate imported streams so a draggable tile can loop without
			# changing later one-shot alphabet or completed-word playback.
			recording = recording.duplicate(true)
			if recording is AudioStreamMP3:
				recording.loop = loop
			player.stream = recording
			player.play()
			playback_started.emit(path)
			call_deferred("_confirm_playback", serial, path, native_text, language_code, phonetic_fallback)
			return
	if not _speak_with_device_voice(native_text, language_code, phonetic_fallback):
		playback_failed.emit(path)


func _confirm_playback(serial: int, path: String, native_text: String, language_code: String, fallback: String) -> void:
	if serial != request_serial:
		return
	if is_instance_valid(player) and player.playing:
		return
	# If a platform decoder rejects the bundled stream, immediately try its
	# native voice instead of failing silently.
	if not _speak_with_device_voice(native_text, language_code, fallback):
		playback_failed.emit(path)


func stop() -> void:
	request_serial += 1
	if is_instance_valid(player):
		player.stop()
	if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		DisplayServer.tts_stop()


func _speak_with_device_voice(text: String, language_code: String, fallback: String) -> bool:
	if text.strip_edges().is_empty() or not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		return false
	var locale := str(ContentData.language(language_code).get("locale", "en-US"))
	var voices := DisplayServer.tts_get_voices_for_language(locale)
	if voices.is_empty():
		voices = DisplayServer.tts_get_voices_for_language(locale.split("-")[0])
	var spoken_text := text
	var voice_id := ""
	if not voices.is_empty():
		voice_id = str(voices[0])
	else:
		var english_voices := DisplayServer.tts_get_voices_for_language("en")
		if not english_voices.is_empty():
			voice_id = str(english_voices[0])
			if not fallback.strip_edges().is_empty():
				spoken_text = fallback
	if voice_id.is_empty():
		return false
	DisplayServer.tts_speak(spoken_text, voice_id, 78, 1.0, 0.9)
	return true


func _exit_tree() -> void:
	stop()
