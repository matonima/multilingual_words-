extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture(filename: String) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png("res://tests/artifacts/%s.png" % filename)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/artifacts"))
	var scene: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await _capture("welcome")
	scene.call("_show_language_selection")
	await _capture("languages")
	scene.call("_choose_language", "ar")
	await _capture("arabic_modes")
	scene.call("_show_alphabet_page")
	await _capture("arabic_alphabet")
	scene.call("_show_words_page")
	await process_frame
	await _capture("arabic_words")
	scene.queue_free()
	await process_frame
	print("Captured UI pages in tests/artifacts")
	quit()
