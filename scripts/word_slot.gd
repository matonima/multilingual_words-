extends PanelContainer

var expected_index := -1
var activity_id := -1
var board
var label: Label


func setup(text: String, index: int, current_activity: int, owner_board, font: Font) -> void:
	expected_index = index
	activity_id = current_activity
	board = owner_board
	var slot_width := clampf(130.0 + maxf(0.0, float(text.length() - 1) * 15.0), 130.0, 200.0)
	custom_minimum_size = Vector2(slot_width, 155)
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	label = Label.new()
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 72 if text.length() <= 2 else 58)
	label.add_theme_color_override("font_color", Color("#fffdf8"))
	label.add_theme_color_override("font_outline_color", Color("#aa9c8e"))
	label.add_theme_constant_override("outline_size", 3)
	add_child(label)


func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("kind") == "word_piece" and int(data.get("activity_id", -2)) == activity_id and int(data.get("target_index", -2)) == expected_index


func _drop_data(_at_position: Vector2, data) -> void:
	board.place_piece(expected_index, data["tile"])


func fill(color: Color) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("#211713"))
	label.add_theme_constant_override("outline_size", 6)


func show_combined(text: String, color: Color) -> void:
	label.text = text
	fill(color)


func hide_in_combination() -> void:
	label.text = ""
