extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error("SMOKE TEST: %s" % message)
		quit(1)


func _run() -> void:
	_check(ContentData.entries("ar").size() == 28, "Arabic content count")
	_check(ContentData.entries("ru").size() == 33, "Russian content count")
	_check(ContentData.entries("sa").size() == 47, "Sanskrit content count")
	_check(ContentData.entries("sa", false).size() == 44, "Sanskrit word count")
	_check(ContentData.entries("la").size() == 23, "Latin content count")
	_check(ContentData.build_pieces("арбуз", "ru") == ["а", "р", "б", "у", "з"], "Russian words must split into individual Cyrillic letters")
	_check(ContentData.build_pieces("صابُون", "ar") == ["ص", "ا", "بُ", "و", "ن"], "Arabic words must split into individual letters while keeping harakat attached")
	_check(ContentData.build_pieces("माता", "sa") == ["म", "ा", "त", "ा"], "Sanskrit vowel signs must be separate spelling pieces")
	_check(ContentData.sanskrit_combined_syllable("क", "ा") == "का", "Sanskrit consonant plus aa-kaar must form kaa")
	for code in ["ar", "ru", "sa", "la"]:
		for entry in ContentData.entries(code, true):
			_check(ResourceLoader.exists(str(entry["letter_audio"])), "missing letter audio %s" % entry["letter_audio"])
			if not str(entry["word"]).is_empty():
				_check(ResourceLoader.exists(str(entry["word_audio"])), "missing word audio %s" % entry["word_audio"])
	for entry in ContentData.entries("sa", false):
		var pieces := ContentData.build_pieces(str(entry["word"]), "sa")
		for index in range(pieces.size()):
			if not ContentData.is_sanskrit_vowel_sign(pieces[index]):
				continue
			_check(ResourceLoader.exists(ContentData.letter_audio_for_piece("sa", pieces[index])), "missing Sanskrit vowel-sign audio")
			if index > 0:
				var syllable := ContentData.sanskrit_combined_syllable(pieces[index - 1], pieces[index])
				if not syllable.is_empty():
					_check(ResourceLoader.exists(ContentData.sanskrit_combination_audio(syllable)), "missing Sanskrit combined-syllable audio")

	var packed_scene := load("res://scenes/main.tscn") as PackedScene
	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	_check(int(scene.get("current_page")) == 0, "welcome page did not open")
	scene.call("_show_language_selection")
	await process_frame
	for code in ["ar", "ru", "sa", "la"]:
		scene.call("_choose_language", code)
		await process_frame
		_check(str(scene.get("selected_language")) == code, "language selection failed for %s" % code)
		scene.call("_show_alphabet_page")
		await process_frame
		scene.call("_step_alphabet", 1)
		await process_frame
		_check(int(scene.get("alphabet_index")) == 1, "alphabet carousel failed for %s" % code)
		scene.call("_show_words_page")
		await process_frame
		await process_frame
		var board: WordBoard = null
		var page_layer: Node = scene.get("page_layer")
		for node in scene.call("_descendants", page_layer):
			if node is WordBoard:
				board = node
				break
		_check(board != null and not board.current_entry.is_empty(), "word board failed for %s" % code)
		scene.call("_show_mode_selection")
		await process_frame
	print("SMOKE TEST PASSED: all pages, datasets, fonts, and 281 voice clips loaded.")
	scene.queue_free()
	await process_frame
	quit()
