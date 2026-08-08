class_name WordBoard
extends PanelContainer

const TileScript := preload("res://scripts/letter_tile.gd")
const SlotScript := preload("res://scripts/word_slot.gd")

signal audio_requested(path: String, text: String, language_code: String, fallback: String, loop: bool)
signal audio_stop_requested

const COLORS := ["#ff5994", "#ff9668", "#edff8f", "#84ff9f", "#82b6ff"]

var current_entry: Dictionary = {}
var activity_id := 0
var language_code := ""
var placed_count := 0
var title_label: Label
var prompt_label: Label
var slots_row: HBoxContainer
var pieces_layer: Control
var result_card: PanelContainer
var result_emoji: Label
var result_word: Label
var replay_button: Button
var reset_button: Button
var slots: Array = []
var tiles: Array = []
var pieces: Array[String] = []
var placed: Array[bool] = []


func _ready() -> void:
	_build()
	resized.connect(_layout_tiles)


func show_entry(entry: Dictionary, entry_id: int) -> void:
	current_entry = entry
	activity_id = entry_id + 1
	language_code = str(entry["language"])
	placed_count = 0
	if not is_node_ready():
		await ready
	_clear_activity()
	var font := ContentData.font_for(language_code)
	title_label.add_theme_font_override("font", font)
	title_label.text = "%s  —  %s" % [entry["letter"], entry["word"]]
	prompt_label.text = "Drag each living piece onto its matching shadow"
	result_word.add_theme_font_override("font", font)
	result_word.text = "%s  •  %s  •  %s" % [entry["word"], entry["say"], entry["english"]]
	result_emoji.text = str(entry["emoji"])
	result_card.visible = false
	reset_button.visible = true
	_build_slots_and_tiles(ContentData.build_pieces(str(entry["word"]), language_code), font)
	call_deferred("_layout_tiles")


func _build() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#ffffffeb")
	style.corner_radius_top_left = 34
	style.corner_radius_top_right = 34
	style.corner_radius_bottom_left = 34
	style.corner_radius_bottom_right = 34
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("#ff9668")
	style.shadow_color = Color("#392d4326")
	style.shadow_size = 12
	add_theme_stylebox_override("panel", style)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	title_label = Label.new()
	title_label.anchor_left = 0.08
	title_label.anchor_right = 0.92
	title_label.offset_top = 22
	title_label.offset_bottom = 78
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 38)
	title_label.add_theme_color_override("font_color", Color("#392d43"))
	root.add_child(title_label)
	prompt_label = Label.new()
	prompt_label.anchor_left = 0.08
	prompt_label.anchor_right = 0.92
	prompt_label.offset_top = 78
	prompt_label.offset_bottom = 112
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 17)
	prompt_label.add_theme_color_override("font_color", Color("#665b70"))
	root.add_child(prompt_label)

	var slots_center := CenterContainer.new()
	slots_center.anchor_left = 0.03
	slots_center.anchor_top = 0.26
	slots_center.anchor_right = 0.97
	slots_center.anchor_bottom = 0.56
	root.add_child(slots_center)
	slots_row = HBoxContainer.new()
	slots_row.add_theme_constant_override("separation", 2)
	slots_center.add_child(slots_row)
	pieces_layer = Control.new()
	pieces_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pieces_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pieces_layer)

	reset_button = Button.new()
	reset_button.text = "↻  Reset"
	reset_button.anchor_left = 1.0
	reset_button.anchor_right = 1.0
	reset_button.offset_left = -142
	reset_button.offset_right = -20
	reset_button.offset_top = 18
	reset_button.offset_bottom = 60
	reset_button.pressed.connect(_reset)
	root.add_child(reset_button)

	result_card = PanelContainer.new()
	result_card.anchor_left = 0.20
	result_card.anchor_top = 0.62
	result_card.anchor_right = 0.80
	result_card.anchor_bottom = 0.94
	var result_style := StyleBoxFlat.new()
	result_style.bg_color = Color("#edff8f")
	result_style.corner_radius_top_left = 26
	result_style.corner_radius_top_right = 26
	result_style.corner_radius_bottom_left = 26
	result_style.corner_radius_bottom_right = 26
	result_style.border_width_left = 3
	result_style.border_width_top = 3
	result_style.border_width_right = 3
	result_style.border_width_bottom = 3
	result_style.border_color = Color("#84ff9f")
	result_card.add_theme_stylebox_override("panel", result_style)
	root.add_child(result_card)
	var result_stack := VBoxContainer.new()
	result_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	result_card.add_child(result_stack)
	result_emoji = Label.new()
	result_emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_emoji.add_theme_font_size_override("font_size", 70)
	result_stack.add_child(result_emoji)
	result_word = Label.new()
	result_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_word.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_word.add_theme_font_size_override("font_size", 24)
	result_word.add_theme_color_override("font_color", Color("#392d43"))
	result_stack.add_child(result_word)
	replay_button = Button.new()
	replay_button.text = "🔊  Hear pronunciation again"
	replay_button.custom_minimum_size = Vector2(250, 48)
	replay_button.add_theme_font_size_override("font_size", 18)
	replay_button.tooltip_text = "Play the completed word again"
	replay_button.pressed.connect(_replay_word)
	result_stack.add_child(replay_button)
	result_card.visible = false


func _build_slots_and_tiles(pieces: Array[String], font: Font) -> void:
	self.pieces = pieces.duplicate()
	placed.resize(pieces.size())
	placed.fill(false)
	if bool(ContentData.language(language_code).get("rtl", false)):
		slots_row.layout_direction = Control.LAYOUT_DIRECTION_RTL
	else:
		slots_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	for index in range(pieces.size()):
		var slot = SlotScript.new()
		slot.setup(pieces[index], index, activity_id, self, font)
		slots_row.add_child(slot)
		slots.append(slot)
	var order := range(pieces.size())
	order.shuffle()
	for original_index in order:
		var tile = TileScript.new()
		var piece_audio := ContentData.letter_audio_for_piece(language_code, pieces[original_index])
		if piece_audio.is_empty():
			piece_audio = str(current_entry["letter_audio"])
		var spoken_piece := pieces[original_index]
		if language_code == "sa" and ContentData.is_sanskrit_vowel_sign(spoken_piece):
			spoken_piece = ContentData.sanskrit_vowel_sign_name(spoken_piece)
		tile.setup(pieces[original_index], original_index, activity_id, self, Color(COLORS[original_index % COLORS.size()]), piece_audio, font, spoken_piece)
		pieces_layer.add_child(tile)
		tiles.append(tile)


func _clear_activity() -> void:
	for child in slots_row.get_children():
		child.queue_free()
	for child in pieces_layer.get_children():
		child.queue_free()
	slots.clear()
	tiles.clear()
	pieces.clear()
	placed.clear()


func _layout_tiles() -> void:
	if tiles.is_empty() or size.x < 100:
		return
	for index in range(tiles.size()):
		if not is_instance_valid(tiles[index]) or not tiles[index].visible:
			continue
		var x := lerpf(size.x * 0.06, size.x * 0.78, float(index) / float(maxi(1, tiles.size() - 1)))
		var y := size.y * (0.66 + (0.06 if index % 2 == 1 else 0.0))
		tiles[index].position = Vector2(x, y)


func place_piece(index: int, tile) -> void:
	if index < 0 or index >= slots.size() or not is_instance_valid(tile):
		return
	stop_audio()
	slots[index].fill(Color(COLORS[index % COLORS.size()]))
	tile.visible = false
	placed[index] = true
	placed_count += 1
	var combined_syllable := _sanskrit_combination_around(index)
	if placed_count == slots.size():
		_complete()
	elif not combined_syllable.is_empty():
		audio_requested.emit(
			ContentData.sanskrit_combination_audio(combined_syllable),
			combined_syllable,
			language_code,
			combined_syllable,
			false
		)


func _sanskrit_combination_around(index: int) -> String:
	if language_code != "sa":
		return ""
	var base_index := -1
	var sign_index := -1
	if ContentData.is_sanskrit_vowel_sign(pieces[index]) and index > 0 and placed[index - 1]:
		base_index = index - 1
		sign_index = index
	elif index + 1 < pieces.size() and placed[index + 1] and ContentData.is_sanskrit_vowel_sign(pieces[index + 1]):
		base_index = index
		sign_index = index + 1
	if base_index < 0:
		return ""
	var syllable := ContentData.sanskrit_combined_syllable(pieces[base_index], pieces[sign_index])
	if syllable.is_empty():
		return ""
	slots[base_index].show_combined(syllable, Color(COLORS[base_index % COLORS.size()]))
	slots[sign_index].hide_in_combination()
	return syllable


func try_proximity_snap(index: int, release_position: Vector2, tile) -> bool:
	if index < 0 or index >= slots.size() or not is_instance_valid(tile):
		return false
	var slot = slots[index]
	var target_center: Vector2 = slot.global_position + slot.size * 0.5
	var offset := release_position - target_center
	if Vector2(offset.x / maxf(115.0, slot.size.x * 0.75), offset.y / 150.0).length() <= 1.0:
		place_piece(index, tile)
		return true
	return false


func start_piece_audio(path: String, fallback_piece: String) -> void:
	audio_requested.emit(path, fallback_piece, language_code, fallback_piece, true)


func stop_audio() -> void:
	audio_stop_requested.emit()


func _complete() -> void:
	prompt_label.text = "Wonderful — you built the word!"
	result_card.visible = true
	audio_requested.emit(str(current_entry["word_audio"]), str(current_entry["word"]), language_code, str(current_entry["say"]), false)


func _replay_word() -> void:
	if current_entry.is_empty():
		return
	audio_requested.emit(str(current_entry["word_audio"]), str(current_entry["word"]), language_code, str(current_entry["say"]), false)


func _reset() -> void:
	show_entry(current_entry, activity_id - 1)
