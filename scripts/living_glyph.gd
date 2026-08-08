class_name LivingGlyph
extends Control

const FaceScript := preload("res://scripts/glyph_face.gd")

signal pressed

var glyph_label: Label
var face
var base_scale := Vector2.ONE
var bob_phase := 0.0
var enabled := true


func setup(text: String, color: Color, font: Font, seed_value: int, font_size := 112) -> void:
	custom_minimum_size = Vector2(150, 170)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	pivot_offset = custom_minimum_size * 0.5
	bob_phase = float(posmod(seed_value * 37, 100)) / 100.0 * TAU

	glyph_label = Label.new()
	glyph_label.text = text
	glyph_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glyph_label.add_theme_font_override("font", font)
	glyph_label.add_theme_font_size_override("font_size", font_size)
	glyph_label.add_theme_color_override("font_color", color)
	glyph_label.add_theme_color_override("font_outline_color", Color("#2b1a17"))
	glyph_label.add_theme_constant_override("outline_size", 7)
	glyph_label.add_theme_color_override("font_shadow_color", Color("#4b2d1b55"))
	glyph_label.add_theme_constant_override("shadow_offset_x", 5)
	glyph_label.add_theme_constant_override("shadow_offset_y", 8)
	add_child(glyph_label)

	face = FaceScript.new()
	face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	face.setup(seed_value, 0.34)
	add_child(face)
	gui_input.connect(_on_gui_input)


func set_text(text: String, font: Font, color: Color, font_size := 112) -> void:
	if not is_instance_valid(glyph_label):
		return
	glyph_label.text = text
	glyph_label.add_theme_font_override("font", font)
	glyph_label.add_theme_font_size_override("font_size", font_size)
	glyph_label.add_theme_color_override("font_color", color)


func celebrate() -> void:
	if is_instance_valid(face):
		face.celebrate()
	var tween := create_tween()
	tween.tween_property(self, "scale", base_scale * 1.13, 0.12).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", base_scale, 0.18).set_trans(Tween.TRANS_BACK)


func _process(_delta: float) -> void:
	if enabled:
		rotation = sin(Time.get_ticks_msec() * 0.0018 + bob_phase) * 0.025


func _on_gui_input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		celebrate()
		pressed.emit()
	elif event is InputEventScreenTouch and event.pressed:
		accept_event()
		celebrate()
		pressed.emit()

