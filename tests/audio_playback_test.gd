extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var service: AudioService = scene.get("audio_service")
	var played_paths: Array[String] = []
	service.playback_started.connect(func(path: String) -> void: played_paths.append(path))
	service.play("res://assets/audio/alphabets/ar/01.mp3", "ا", "ar", "alif")
	await process_frame
	var stream := service.player.stream
	if stream == null:
		push_error("AUDIO TEST: no stream was assigned")
		quit(1)
		return
	print("AUDIO TEST stream=", stream.get_class(), " length=", stream.get_length(), " playing=", service.player.playing, " bus=", service.player.bus, " master_db=", AudioServer.get_bus_volume_db(0), " master_mute=", AudioServer.is_bus_mute(0))
	if stream.get_length() <= 0.05 or not service.player.playing:
		push_error("AUDIO TEST: the pronunciation stream did not start")
		quit(1)
		return

	scene.call("_choose_language", "ar")
	scene.call("_show_alphabet_page")
	await process_frame
	var alphabet_buttons: Array = scene.get("carousel_buttons")
	alphabet_buttons[4].pressed.emit()
	await process_frame
	if not service.player.playing:
		push_error("AUDIO TEST: alphabet carousel click did not start audio")
		quit(1)
		return
	print("AUDIO TEST alphabet carousel click passed")

	scene.call("_show_words_page")
	await process_frame
	await process_frame
	var word_carousel: WordCarousel = null
	for node in scene.call("_descendants", scene.get("page_layer")):
		if node is WordCarousel:
			word_carousel = node
			break
	if word_carousel == null:
		push_error("AUDIO TEST: word carousel was not created")
		quit(1)
		return
	word_carousel.letter_buttons[4].pressed.emit()
	await process_frame
	if not service.player.playing:
		push_error("AUDIO TEST: word carousel click did not start audio")
		quit(1)
		return
	print("AUDIO TEST word carousel click passed")

	var board: WordBoard = null
	for node in scene.call("_descendants", scene.get("page_layer")):
		if node is WordBoard:
			board = node
			break
	if board == null or board.tiles.is_empty():
		push_error("AUDIO TEST: living word tiles were not created")
		quit(1)
		return
	var first_tile = board.tiles[0]
	board.start_piece_audio(first_tile.pronunciation_path, first_tile.piece_text)
	await process_frame
	if not service.player.playing or not (service.player.stream is AudioStreamMP3) or not service.player.stream.loop:
		push_error("AUDIO TEST: held word tile did not start looping")
		quit(1)
		return
	print("AUDIO TEST held living letter loops until release/drop")

	# Accepting an Arabic RTL drop must not let drag-end accept that tile again.
	board.place_piece(first_tile.target_index, first_tile)
	board.place_piece(first_tile.target_index, first_tile)
	if board.placed_count != 1 or not board.placed[first_tile.target_index]:
		push_error("AUDIO TEST: one Arabic tile was counted more than once")
		quit(1)
		return
	var visible_unplaced_tiles := 0
	for tile in board.tiles:
		if is_instance_valid(tile) and tile.visible:
			visible_unplaced_tiles += 1
	if visible_unplaced_tiles != board.tiles.size() - 1:
		push_error("AUDIO TEST: placing one Arabic tile changed another tile")
		quit(1)
		return
	print("AUDIO TEST Arabic tile placement is idempotent")

	# Completing every slot must replace the loop with the one-shot word clip.
	var final_tile = null
	for tile in board.tiles:
		if is_instance_valid(tile) and tile.visible:
			final_tile = tile
			board.place_piece(tile.target_index, tile)
	# Simulate the release notification that follows the accepted final drop.
	board.finish_piece_audio(final_tile.target_index)
	await process_frame
	await process_frame
	if not service.player.playing or (service.player.stream is AudioStreamMP3 and service.player.stream.loop):
		push_error("AUDIO TEST: completed word did not play once")
		quit(1)
		return
	var completed_word_path := str(board.current_entry["word_audio"])
	if played_paths.is_empty() or played_paths.back() != completed_word_path:
		push_error("AUDIO TEST: completed Arabic word recording was not selected")
		quit(1)
		return
	print("AUDIO TEST completed spelling plays the whole word once")
	board.replay_button.pressed.emit()
	await process_frame
	if not service.player.playing or service.player.stream.loop or played_paths.is_empty() or played_paths.back() != completed_word_path:
		push_error("AUDIO TEST: replay pronunciation button did not replay the completed word")
		quit(1)
		return
	print("AUDIO TEST replay pronunciation button passed")

	# Sanskrit vowel signs are independent learning pieces, but become one
	# displayed and spoken syllable when joined to the preceding consonant.
	var mother_entry: Dictionary = {}
	for entry in ContentData.entries("sa", false):
		if str(entry["word"]) == "माता":
			mother_entry = entry
			break
	if mother_entry.is_empty():
		push_error("AUDIO TEST: Sanskrit माता entry is missing")
		quit(1)
		return
	board.show_entry(mother_entry, int(mother_entry["index"]))
	await process_frame
	await process_frame
	if board.pieces != ["म", "ा", "त", "ा"]:
		push_error("AUDIO TEST: Sanskrit vowel signs were not split from consonants")
		quit(1)
		return
	var ma_tile = null
	var aa_kaar_tile = null
	for tile in board.tiles:
		if tile.target_index == 0:
			ma_tile = tile
		elif tile.target_index == 1:
			aa_kaar_tile = tile
	board.place_piece(0, ma_tile)
	board.start_piece_audio(aa_kaar_tile.pronunciation_path, aa_kaar_tile.spoken_text)
	await process_frame
	if not service.player.playing or not service.player.stream.loop:
		push_error("AUDIO TEST: held Sanskrit aa-kaar did not repeat")
		quit(1)
		return
	board.place_piece(1, aa_kaar_tile)
	await process_frame
	if board.slots[0].label.text != "मा" or board.slots[1].label.text != "":
		push_error("AUDIO TEST: ma plus aa-kaar did not display as maa")
		quit(1)
		return
	if not service.player.playing or service.player.stream.loop or played_paths.is_empty() or not played_paths.back().contains("combo_092e_093e"):
		push_error("AUDIO TEST: ma plus aa-kaar did not play the combined maa syllable")
		quit(1)
		return
	print("AUDIO TEST Sanskrit consonant + vowel-kaar composition passed")

	scene.queue_free()
	await process_frame
	print("AUDIO PLAYBACK TEST PASSED")
	quit()
