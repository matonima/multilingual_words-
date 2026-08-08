extends SceneTree


func _initialize() -> void:
	var samples := {
		"Latin aqua": "res://assets/audio/words/la/01.mp3",
		"Latin Kalendae": "res://assets/audio/words/la/10.mp3",
		"Latin quattuor": "res://assets/audio/words/la/16.mp3",
		"Sanskrit agni": "res://assets/audio/words/sa/01.mp3",
		"Sanskrit ishvara": "res://assets/audio/words/sa/04.mp3",
		"Sanskrit jhasha": "res://assets/audio/words/sa/23.mp3",
	}
	var failed := false
	for label in samples:
		var stream = load(samples[label])
		if not stream is AudioStreamMP3 or stream.get_length() < 0.25:
			push_error("Invalid pronunciation clip: %s" % label)
			failed = true
		else:
			print("PRONUNCIATION ASSET %s length=%.3f" % [label, stream.get_length()])
	if failed:
		quit(1)
	else:
		print("PRONUNCIATION ASSET TEST PASSED")
		quit()
