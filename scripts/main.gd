extends Control

const WheelScript := preload("res://scripts/ferris_wheel.gd")
const GlyphScript := preload("res://scripts/living_glyph.gd")
const CarouselScript := preload("res://scripts/word_carousel.gd")
const BoardScript := preload("res://scripts/word_board.gd")
const AudioScript := preload("res://scripts/audio_service.gd")
const CardArtScript := preload("res://scripts/card_art.gd")
const UI_FONT := preload("res://assets/fonts/NotoSans-Variable.ttf")

enum Page { WELCOME, LANGUAGES, MODES, ALPHABET, WORDS }

const PALETTE_PINK := Color("#ff5994")
const PALETTE_ORANGE := Color("#ff9668")
const PALETTE_YELLOW := Color("#edff8f")
const PALETTE_GREEN := Color("#84ff9f")
const PALETTE_BLUE := Color("#82b6ff")
const OCEAN := Color("#00b1c1")
const DEEP_OCEAN := Color("#0184ba")
const MINT := Color("#00d39e")
const SUN := Color("#fddf03")
const HOT_PINK := Color("#fe005d")
const INK := Color("#26384a")
const MUTED_INK := Color("#587080")
const PALETTE := [
	PALETTE_PINK, PALETTE_ORANGE, PALETTE_YELLOW,
	PALETTE_GREEN, PALETTE_BLUE, OCEAN, DEEP_OCEAN, MINT, SUN, HOT_PINK
]

var current_page := Page.WELCOME
var selected_language := ""
var alphabet_entries: Array[Dictionary] = []
var alphabet_index := 0
var page_layer: Control
var audio_service: AudioService
var alphabet_glyph: LivingGlyph
var alphabet_info: Label
var alphabet_word: Label
var carousel_buttons: Array[Button] = []


func _ready() -> void:
	theme = _make_theme()
	audio_service = AudioScript.new()
	add_child(audio_service)
	page_layer = Control.new()
	page_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page_layer)
	_show_welcome()


func _show_welcome() -> void:
	current_page = Page.WELCOME
	selected_language = ""
	_clear_page()
	_add_background(HOT_PINK.lightened(0.92))

	var title := Label.new()
	title.text = "Welcome to Words"
	title.anchor_left = 0.18
	title.anchor_right = 0.82
	title.offset_top = 22
	title.offset_bottom = 92
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", INK)
	page_layer.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Touch any living alphabet to begin"
	subtitle.anchor_left = 0.25
	subtitle.anchor_right = 0.75
	subtitle.offset_top = 90
	subtitle.offset_bottom = 130
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 21)
	subtitle.add_theme_color_override("font_color", MUTED_INK)
	page_layer.add_child(subtitle)

	var wheel = WheelScript.new()
	wheel.anchor_left = 0.24
	wheel.anchor_top = 0.17
	wheel.anchor_right = 0.76
	wheel.anchor_bottom = 0.95
	wheel.alphabet_touched.connect(_show_language_selection)
	page_layer.add_child(wheel)


func _show_language_selection() -> void:
	current_page = Page.LANGUAGES
	_clear_page()
	_add_background(OCEAN.lightened(0.91))
	var root := _page_stack("Choose a language", "Four worlds of letters, sounds, and first words", true)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 20)
	root.add_child(grid)
	for code in ["ar", "ru", "sa", "la"]:
		var data := ContentData.language(code)
		var card := _language_card(code, data)
		card.pressed.connect(_choose_language.bind(code))
		grid.add_child(card)


func _choose_language(code: String) -> void:
	selected_language = code
	_show_mode_selection()


func _show_mode_selection() -> void:
	if selected_language.is_empty():
		_show_language_selection()
		return
	current_page = Page.MODES
	_clear_page()
	_add_background(DEEP_OCEAN.lightened(0.91))
	var language := ContentData.language(selected_language)
	var root := _page_stack("%s • %s" % [language["name"], language["english_name"]], "Choose a picture to start", true)
	root.get_child(0).add_theme_font_override("font", ContentData.font_for(selected_language))
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 44)
	root.add_child(row)
	var alphabet_button := _mode_button("alphabet", DEEP_OCEAN)
	alphabet_button.pressed.connect(_show_alphabet_page)
	row.add_child(alphabet_button)
	var word_button := _mode_button("words", HOT_PINK)
	word_button.pressed.connect(_show_words_page)
	row.add_child(word_button)


func _show_alphabet_page() -> void:
	current_page = Page.ALPHABET
	alphabet_entries = ContentData.entries(selected_language, true)
	alphabet_index = 0
	_clear_page()
	_add_background(DEEP_OCEAN.lightened(0.91))
	var content := _content_below_header("Alphabet Carousel", _show_mode_selection)
	var stack := VBoxContainer.new()
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 7)
	content.add_child(stack)

	alphabet_info = Label.new()
	alphabet_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alphabet_info.add_theme_font_size_override("font_size", 20)
	alphabet_info.add_theme_color_override("font_color", MUTED_INK)
	stack.add_child(alphabet_info)
	var center_row := HBoxContainer.new()
	center_row.alignment = BoxContainer.ALIGNMENT_CENTER
	center_row.add_theme_constant_override("separation", 45)
	center_row.custom_minimum_size.y = 320
	stack.add_child(center_row)
	var previous := _round_arrow("‹")
	previous.pressed.connect(_step_alphabet.bind(-1))
	center_row.add_child(previous)
	alphabet_glyph = GlyphScript.new()
	alphabet_glyph.custom_minimum_size = Vector2(310, 300)
	alphabet_glyph.setup("A", PALETTE[0], ContentData.font_for(selected_language), 0, 190)
	alphabet_glyph.pressed.connect(_speak_current_alphabet)
	center_row.add_child(alphabet_glyph)
	var next := _round_arrow("›")
	next.pressed.connect(_step_alphabet.bind(1))
	center_row.add_child(next)
	alphabet_word = Label.new()
	alphabet_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alphabet_word.add_theme_font_override("font", ContentData.font_for(selected_language))
	alphabet_word.add_theme_font_size_override("font_size", 30)
	alphabet_word.add_theme_color_override("font_color", INK)
	stack.add_child(alphabet_word)
	var hint := Label.new()
	hint.text = "Tap the big living letter to hear its sound"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_color_override("font_color", MUTED_INK)
	stack.add_child(hint)
	var strip := HBoxContainer.new()
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	strip.add_theme_constant_override("separation", 12)
	strip.custom_minimum_size.y = 92
	stack.add_child(strip)
	carousel_buttons.clear()
	for visible_index in range(9):
		var button := Button.new()
		button.custom_minimum_size = Vector2(78, 72)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_override("font", ContentData.font_for(selected_language))
		button.add_theme_font_size_override("font_size", 28)
		button.pressed.connect(_select_carousel_button.bind(visible_index))
		strip.add_child(button)
		carousel_buttons.append(button)
	_refresh_alphabet()


func _step_alphabet(direction: int) -> void:
	if alphabet_entries.is_empty():
		return
	alphabet_index = posmod(alphabet_index + direction, alphabet_entries.size())
	_refresh_alphabet()
	_speak_current_alphabet()


func _select_carousel_button(visible_index: int) -> void:
	var button := carousel_buttons[visible_index]
	alphabet_index = int(button.get_meta("entry_index", alphabet_index))
	_refresh_alphabet()
	_speak_current_alphabet()


func _refresh_alphabet() -> void:
	if alphabet_entries.is_empty() or not is_instance_valid(alphabet_glyph):
		return
	var entry := alphabet_entries[alphabet_index]
	var font := ContentData.font_for(selected_language)
	var display_size := 150 if str(entry["letter"]).length() > 2 else 190
	alphabet_glyph.set_text(str(entry["letter"]), font, PALETTE[alphabet_index % PALETTE.size()], display_size)
	alphabet_info.text = "%s alphabet  •  %d of %d" % [ContentData.language(selected_language)["english_name"], alphabet_index + 1, alphabet_entries.size()]
	if str(entry["word"]).is_empty():
		alphabet_word.text = "%s  •  %s" % [entry["say"], entry["english"]]
	else:
		alphabet_word.text = "%s  •  %s  •  %s" % [entry["word"], entry["say"], entry["english"]]
	for visible_index in range(carousel_buttons.size()):
		var offset := visible_index - carousel_buttons.size() / 2
		var data_index := posmod(alphabet_index + offset, alphabet_entries.size())
		var button := carousel_buttons[visible_index]
		button.text = str(alphabet_entries[data_index]["letter"])
		button.set_meta("entry_index", data_index)
		button.modulate = Color.WHITE if data_index == alphabet_index else Color("#ffffffb0")
		button.scale = Vector2.ONE * (1.12 if data_index == alphabet_index else 0.92)
		button.pivot_offset = button.size * 0.5


func _speak_current_alphabet() -> void:
	if alphabet_entries.is_empty():
		return
	var entry := alphabet_entries[alphabet_index]
	audio_service.play(str(entry["letter_audio"]), str(entry["letter"]), selected_language, str(entry["say"]))


func _show_words_page() -> void:
	current_page = Page.WORDS
	var word_entries := ContentData.entries(selected_language, false)
	_clear_page()
	_add_background(SUN.lightened(0.86))
	var content := _content_below_header("Level 1 Words", _show_mode_selection)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	content.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	margin.add_child(row)
	var carousel = CarouselScript.new()
	carousel.custom_minimum_size = Vector2(350, 0)
	carousel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	carousel.setup(word_entries, selected_language)
	carousel.entry_selected.connect(_on_word_selected.bind(word_entries))
	carousel.pronunciation_requested.connect(_on_word_pronunciation)
	row.add_child(carousel)
	var board = BoardScript.new()
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board.audio_requested.connect(_on_board_audio_requested)
	board.audio_stop_requested.connect(audio_service.stop)
	row.add_child(board)
	if not word_entries.is_empty():
		board.show_entry(word_entries[0], 0)
	carousel.set_meta("board", board)


func _on_word_selected(index: int, entries: Array[Dictionary]) -> void:
	if index < 0 or index >= entries.size():
		return
	# Find the active board on this page; there is exactly one.
	for node in _descendants(page_layer):
		if node is WordBoard:
			node.show_entry(entries[index], index)
			break


func _on_word_pronunciation(entry: Dictionary) -> void:
	audio_service.play(str(entry["letter_audio"]), str(entry["letter"]), str(entry["language"]), str(entry["say"]))


func _on_board_audio_requested(path: String, text: String, language_code: String, fallback: String, loop: bool) -> void:
	audio_service.play(path, text, language_code, fallback, loop)


func _descendants(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_descendants(child))
	return result


func _clear_page() -> void:
	if is_instance_valid(audio_service):
		audio_service.stop()
	for child in page_layer.get_children():
		child.queue_free()
	carousel_buttons.clear()


func _add_background(color: Color) -> void:
	var background := ColorRect.new()
	background.color = color
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_layer.add_child(background)
	_add_glow(Vector2(-120, 100), Color("#00d39e88"))
	_add_glow(Vector2(890, -130), Color("#fe005d77"))


func _add_glow(position: Vector2, color: Color) -> void:
	var texture := GradientTexture2D.new()
	texture.width = 512
	texture.height = 512
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([color, Color(color.r, color.g, color.b, 0.0)])
	texture.gradient = gradient
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = position
	rect.size = Vector2(600, 600)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_layer.add_child(rect)


func _page_stack(title_text: String, subtitle_text: String, include_back: bool) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 100)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 100)
	margin.add_theme_constant_override("margin_bottom", 42)
	page_layer.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 15)
	margin.add_child(root)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 58
	root.add_child(header)
	if include_back:
		var back := Button.new()
		back.text = "‹  Back"
		back.custom_minimum_size = Vector2(120, 50)
		back.pressed.connect(_go_back)
		header.add_child(back)
	var title := Label.new()
	title.text = title_text
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", INK)
	header.add_child(title)
	if include_back:
		var spacer := Control.new()
		spacer.custom_minimum_size.x = 120
		header.add_child(spacer)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 19)
	subtitle.add_theme_color_override("font_color", MUTED_INK)
	root.add_child(subtitle)
	return root


func _content_below_header(title_text: String, back_callable: Callable) -> Control:
	var header := PanelContainer.new()
	header.anchor_right = 1.0
	header.offset_left = 22
	header.offset_top = 14
	header.offset_right = -22
	header.offset_bottom = 78
	header.add_theme_stylebox_override("panel", _header_style())
	page_layer.add_child(header)
	var row := HBoxContainer.new()
	header.add_child(row)
	var back := Button.new()
	back.text = "‹  Activities"
	back.custom_minimum_size.x = 150
	back.pressed.connect(back_callable)
	row.add_child(back)
	var title := Label.new()
	title.text = "%s • %s" % [ContentData.language(selected_language)["english_name"], title_text]
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 29)
	title.add_theme_color_override("font_color", INK)
	row.add_child(title)
	var home := Button.new()
	home.text = "⌂  Home"
	home.custom_minimum_size.x = 150
	home.pressed.connect(_show_welcome)
	row.add_child(home)
	var content := Control.new()
	content.anchor_top = 0.0
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_top = 88
	page_layer.add_child(content)
	return content


func _go_back() -> void:
	match current_page:
		Page.LANGUAGES:
			_show_welcome()
		Page.MODES:
			_show_language_selection()
		Page.ALPHABET, Page.WORDS:
			_show_mode_selection()
		_:
			_show_welcome()


func _language_card(code: String, data: Dictionary) -> Button:
	var accent := Color(data["accent"])
	var button := Button.new()
	button.text = ""
	button.clip_contents = true
	button.custom_minimum_size = Vector2(440, 218)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _language_card_style(accent, false))
	button.add_theme_stylebox_override("hover", _language_card_style(accent, true))
	button.add_theme_stylebox_override("pressed", _language_card_style(accent.darkened(0.06), true))

	var art = CardArtScript.new()
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.setup(accent, "language")
	button.add_child(art)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 2)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)

	var english := Label.new()
	english.text = str(data["english_name"]).to_upper()
	english.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	english.add_theme_font_size_override("font_size", 17)
	english.add_theme_color_override("font_color", INK)
	english.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(english)
	var native := Label.new()
	native.text = str(data["name"])
	native.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	native.add_theme_font_override("font", ContentData.font_for(code))
	native.add_theme_font_size_override("font_size", 33)
	native.add_theme_color_override("font_color", INK)
	native.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(native)
	var sample := Label.new()
	sample.text = str(data["sample"])
	sample.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sample.add_theme_font_override("font", ContentData.font_for(code))
	sample.add_theme_font_size_override("font_size", 39)
	sample.add_theme_color_override("font_color", accent.darkened(0.24))
	sample.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(sample)
	var count := Label.new()
	count.text = "%d letters  •  Alphabet + Words" % ContentData.entries(code, true).size()
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count.add_theme_font_size_override("font_size", 15)
	count.add_theme_color_override("font_color", MUTED_INK)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(count)
	return button


func _mode_button(kind: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = ""
	button.clip_contents = true
	button.custom_minimum_size = Vector2(430, 420)
	button.add_theme_stylebox_override("normal", _language_card_style(accent, false))
	button.add_theme_stylebox_override("hover", _language_card_style(accent, true))
	button.add_theme_stylebox_override("pressed", _language_card_style(accent.darkened(0.08), true))
	var art = CardArtScript.new()
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.setup(accent, kind)
	button.add_child(art)
	_add_activity_preview(button, kind, accent)
	return button


func _add_activity_preview(button: Button, kind: String, accent: Color) -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 12)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)
	var preview := HBoxContainer.new()
	preview.custom_minimum_size.y = 225
	preview.alignment = BoxContainer.ALIGNMENT_CENTER
	preview.add_theme_constant_override("separation", 9)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(preview)
	var entries := ContentData.entries(selected_language, false)
	var symbols: Array[String] = []
	if kind == "alphabet":
		var alphabet := ContentData.entries(selected_language, true)
		for index in range(mini(3, alphabet.size())):
			symbols.append(str(alphabet[index]["letter"]))
	else:
		if not entries.is_empty():
			var built := ContentData.build_pieces(str(entries[0]["word"]), selected_language)
			for index in range(mini(4, built.size())):
				symbols.append(str(built[index]))
	for index in range(symbols.size()):
		if kind == "alphabet":
			var glyph = GlyphScript.new()
			glyph.setup(symbols[index], PALETTE[(index + 5) % PALETTE.size()], ContentData.font_for(selected_language), index + 10, 76)
			glyph.custom_minimum_size = Vector2(112, 145)
			glyph.enabled = false
			glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
			preview.add_child(glyph)
		else:
			var tile := PanelContainer.new()
			tile.custom_minimum_size = Vector2(82, 92)
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var tile_style := StyleBoxFlat.new()
			tile_style.bg_color = PALETTE[(index + 5) % PALETTE.size()].lightened(0.58)
			tile_style.border_color = accent
			tile_style.set_border_width_all(4)
			tile_style.set_corner_radius_all(20)
			tile_style.shadow_color = Color("#26384a33")
			tile_style.shadow_size = 5
			tile.add_theme_stylebox_override("panel", tile_style)
			var letter := Label.new()
			letter.text = symbols[index]
			letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			letter.add_theme_font_override("font", ContentData.font_for(selected_language))
			letter.add_theme_font_size_override("font_size", 46 if symbols[index].length() <= 2 else 36)
			letter.add_theme_color_override("font_color", INK)
			letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(letter)
			preview.add_child(tile)
	var title := Label.new()
	title.text = "ALPHABET" if kind == "alphabet" else "WORDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", INK)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(title)
	var cue := Label.new()
	cue.text = "Meet each letter" if kind == "alphabet" else "Build the whole word"
	cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cue.add_theme_font_size_override("font_size", 18)
	cue.add_theme_color_override("font_color", MUTED_INK)
	cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(cue)


func _round_arrow(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(100, 100)
	button.add_theme_font_size_override("font_size", 54)
	return button


func _language_card_style(accent: Color, active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE if not active else accent.lightened(0.78)
	style.corner_radius_top_left = 30
	style.corner_radius_top_right = 30
	style.corner_radius_bottom_left = 30
	style.corner_radius_bottom_right = 30
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	style.border_color = accent
	style.shadow_color = Color(accent.r, accent.g, accent.b, 0.34)
	style.shadow_size = 14 if not active else 7
	style.shadow_offset = Vector2(0, 7)
	return style


func _header_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#ffffffeb")
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = OCEAN
	return style


func _make_theme() -> Theme:
	var result := Theme.new()
	result.default_font = UI_FONT
	result.default_font_size = 18
	var normal := StyleBoxFlat.new()
	normal.bg_color = SUN
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = OCEAN
	normal.shadow_color = Color("#26384a38")
	normal.shadow_size = 5
	normal.shadow_offset = Vector2(0, 3)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = MINT.lightened(0.55)
	hover.border_color = DEEP_OCEAN
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = MINT
	pressed.shadow_size = 2
	result.set_stylebox("normal", "Button", normal)
	result.set_stylebox("hover", "Button", hover)
	result.set_stylebox("pressed", "Button", pressed)
	result.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	result.set_color("font_color", "Button", INK)
	result.set_color("font_hover_color", "Button", INK)
	result.set_color("font_pressed_color", "Button", INK)
	return result
