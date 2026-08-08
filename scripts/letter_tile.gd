extends PanelContainer

const FaceScript := preload("res://scripts/glyph_face.gd")

var piece_text := ""
var target_index := -1
var activity_id := -1
var board
var text_label: Label
var character_color := Color.WHITE
var pronunciation_path := ""
var spoken_text := ""
var tile_font: Font


func setup(text: String, index: int, current_activity: int, owner_board, color: Color, audio_path: String, font: Font, audio_text := "") -> void:
	piece_text = text
	spoken_text = audio_text if not audio_text.is_empty() else text
	target_index = index
	activity_id = current_activity
	board = owner_board
	character_color = color
	pronunciation_path = audio_path
	tile_font = font
	var tile_width := clampf(110.0 + maxf(0.0, float(text.length() - 1) * 15.0), 110.0, 190.0)
	custom_minimum_size = Vector2(tile_width, 128)
	size = custom_minimum_size
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	text_label = Label.new()
	text_label.text = text
	text_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.add_theme_font_override("font", tile_font)
	text_label.add_theme_font_size_override("font_size", 76 if text.length() <= 2 else 62)
	text_label.add_theme_color_override("font_color", color)
	text_label.add_theme_color_override("font_outline_color", Color("#211713"))
	text_label.add_theme_constant_override("outline_size", 6)
	text_label.add_theme_color_override("font_shadow_color", Color("#4b2d1b55"))
	text_label.add_theme_constant_override("shadow_offset_x", 5)
	text_label.add_theme_constant_override("shadow_offset_y", 8)
	add_child(text_label)

	var face = FaceScript.new()
	face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	face.setup(activity_id + target_index)
	add_child(face)
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	# A tap speaks the piece even when the child does not begin a drag.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_instance_valid(board):
			board.start_piece_audio(pronunciation_path, spoken_text)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_instance_valid(board):
			board.stop_audio()
	elif event is InputEventScreenTouch and event.pressed:
		if is_instance_valid(board):
			board.start_piece_audio(pronunciation_path, spoken_text)
	elif event is InputEventScreenTouch and not event.pressed:
		if is_instance_valid(board):
			board.stop_audio()


func _get_drag_data(_at_position: Vector2):
	if is_instance_valid(board):
		board.start_piece_audio(pronunciation_path, spoken_text)
	var preview := PanelContainer.new()
	preview.custom_minimum_size = size
	preview.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var preview_label := Label.new()
	preview_label.text = piece_text
	preview_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_override("font", tile_font)
	preview_label.add_theme_font_size_override("font_size", 76 if piece_text.length() <= 2 else 62)
	preview_label.add_theme_color_override("font_color", character_color)
	preview_label.add_theme_color_override("font_outline_color", Color("#211713"))
	preview_label.add_theme_constant_override("outline_size", 6)
	preview.add_child(preview_label)
	var preview_face = FaceScript.new()
	preview_face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_face.setup(activity_id + target_index)
	preview.add_child(preview_face)
	set_drag_preview(preview)
	modulate.a = 0.35
	return {"kind": "word_piece", "target_index": target_index, "activity_id": activity_id, "tile": self}


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and is_instance_valid(self):
		modulate.a = 1.0
		var successful := is_drag_successful()
		var snapped := false
		if not successful and is_instance_valid(board):
			snapped = board.try_proximity_snap(target_index, get_viewport().get_mouse_position(), self)
		if not successful and not snapped and is_instance_valid(board):
			board.stop_audio()
