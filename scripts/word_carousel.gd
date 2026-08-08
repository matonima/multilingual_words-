class_name WordCarousel
extends PanelContainer

signal entry_selected(index: int)
signal pronunciation_requested(entry: Dictionary)

const VISIBLE_COUNT := 9

var entries: Array[Dictionary] = []
var selected_index := 0
var language_code := ""
var letter_buttons: Array[Button] = []
var ring: Control
var center_letter: Label
var word_label: Label


func setup(value: Array[Dictionary], code: String) -> void:
	entries = value
	language_code = code
	selected_index = 0
	if is_node_ready():
		_refresh()


func _ready() -> void:
	_build()


func _build() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#ffffffdc")
	style.corner_radius_top_left = 34
	style.corner_radius_top_right = 34
	style.corner_radius_bottom_left = 34
	style.corner_radius_bottom_right = 34
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("#82b6ff")
	style.shadow_color = Color("#392d4326")
	style.shadow_size = 12
	add_theme_stylebox_override("panel", style)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 3)
	add_child(root)
	var title := Label.new()
	title.text = "Word Wheel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("#392d43"))
	root.add_child(title)
	var hint := Label.new()
	hint.text = "Choose a living letter"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color("#665b70"))
	root.add_child(hint)

	ring = Control.new()
	ring.custom_minimum_size = Vector2(340, 520)
	ring.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(ring)
	var disc := Panel.new()
	disc.position = Vector2(45, 78)
	disc.size = Vector2(250, 250)
	disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var disc_style := StyleBoxFlat.new()
	disc_style.bg_color = Color("#edff8f")
	disc_style.corner_radius_top_left = 140
	disc_style.corner_radius_top_right = 140
	disc_style.corner_radius_bottom_left = 140
	disc_style.corner_radius_bottom_right = 140
	disc_style.border_width_left = 5
	disc_style.border_width_top = 5
	disc_style.border_width_right = 5
	disc_style.border_width_bottom = 5
	disc_style.border_color = Color("#ff9668")
	disc.add_theme_stylebox_override("panel", disc_style)
	ring.add_child(disc)

	center_letter = Label.new()
	center_letter.position = Vector2(87, 125)
	center_letter.size = Vector2(166, 120)
	center_letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center_letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_letter.add_theme_font_size_override("font_size", 68)
	center_letter.add_theme_color_override("font_color", Color("#ff5994"))
	ring.add_child(center_letter)
	word_label = Label.new()
	word_label.position = Vector2(35, 342)
	word_label.size = Vector2(270, 68)
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	word_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	word_label.add_theme_font_size_override("font_size", 22)
	word_label.add_theme_color_override("font_color", Color("#392d43"))
	ring.add_child(word_label)

	for visible_index in range(VISIBLE_COUNT):
		var button := Button.new()
		button.size = Vector2(60, 60)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 27)
		button.pressed.connect(_on_ring_pressed.bind(visible_index))
		ring.add_child(button)
		letter_buttons.append(button)

	var previous := Button.new()
	previous.text = "‹"
	previous.position = Vector2(62, 430)
	previous.size = Vector2(78, 54)
	previous.add_theme_font_size_override("font_size", 34)
	previous.pressed.connect(_step.bind(-1))
	ring.add_child(previous)
	var next := Button.new()
	next.text = "›"
	next.position = Vector2(200, 430)
	next.size = Vector2(78, 54)
	next.add_theme_font_size_override("font_size", 34)
	next.pressed.connect(_step.bind(1))
	ring.add_child(next)
	_refresh()


func _refresh() -> void:
	if entries.is_empty() or letter_buttons.is_empty():
		return
	var font := ContentData.font_for(language_code)
	center_letter.add_theme_font_override("font", font)
	center_letter.text = str(entries[selected_index]["letter"])
	word_label.add_theme_font_override("font", font)
	word_label.text = "%s  •  %s" % [entries[selected_index]["word"], entries[selected_index]["english"]]
	var radius := 142.0
	var center := Vector2(170, 205)
	for visible_index in range(VISIBLE_COUNT):
		var offset := visible_index - VISIBLE_COUNT / 2
		var data_index := posmod(selected_index + offset, entries.size())
		var angle := -PI * 0.5 + TAU * float(visible_index) / float(VISIBLE_COUNT)
		var button := letter_buttons[visible_index]
		button.text = str(entries[data_index]["letter"])
		button.add_theme_font_override("font", font)
		button.set_meta("entry_index", data_index)
		button.position = center + Vector2(cos(angle), sin(angle)) * radius - button.size * 0.5
		button.modulate = Color.WHITE if data_index == selected_index else Color("#82b6ffb8")
		button.scale = Vector2.ONE * (1.12 if data_index == selected_index else 0.92)
		button.pivot_offset = button.size * 0.5


func _on_ring_pressed(visible_index: int) -> void:
	_select(int(letter_buttons[visible_index].get_meta("entry_index")))


func _step(direction: int) -> void:
	if not entries.is_empty():
		_select(posmod(selected_index + direction, entries.size()))


func _select(index: int) -> void:
	selected_index = index
	_refresh()
	entry_selected.emit(index)
	pronunciation_requested.emit(entries[index])
