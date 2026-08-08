extends SceneTree


func _initialize() -> void:
	var manifest := {"languages": {}}
	for code in ["ar", "ru", "sa", "la"]:
		manifest["languages"][code] = {
			"language": ContentData.language(code),
			"entries": ContentData.entries(code, true)
		}
	var file := FileAccess.open("res://data/voice_manifest.json", FileAccess.WRITE)
	if file == null:
		push_error("Could not write voice manifest")
		quit(1)
		return
	file.store_string(JSON.stringify(manifest, "  ", false))
	file.close()
	print("Wrote data/voice_manifest.json")
	quit()

