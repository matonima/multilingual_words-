class_name FerrisAlphabetWheel
extends Control

const GlyphScript := preload("res://scripts/living_glyph.gd")

signal alphabet_touched

const CABINS := [
	["ا", "ar"], ["Б", "ru"], ["अ", "sa"], ["A", "la"],
	["ش", "ar"], ["Я", "ru"], ["क", "sa"], ["V", "la"],
	["م", "ar"], ["Ж", "ru"], ["स", "sa"], ["Q", "la"]
]
const COLORS := ["#fe005d", "#00b1c1", "#fddf03", "#00d39e", "#0184ba", "#ff5994", "#ff9668", "#82b6ff"]

var cabins: Array[Control] = []
var wheel_angle := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index in range(CABINS.size()):
		var row: Array = CABINS[index]
		var glyph = GlyphScript.new()
		glyph.setup(str(row[0]), Color(COLORS[index % COLORS.size()]), ContentData.font_for(str(row[1])), index, 58)
		glyph.custom_minimum_size = Vector2(82, 94)
		glyph.size = Vector2(82, 94)
		glyph.pivot_offset = glyph.size * 0.5
		glyph.pressed.connect(_on_glyph_pressed)
		add_child(glyph)
		cabins.append(glyph)
	resized.connect(_layout_cabins)
	call_deferred("_layout_cabins")


func _process(delta: float) -> void:
	wheel_angle += delta * 0.12
	_layout_cabins()
	queue_redraw()


func _layout_cabins() -> void:
	if cabins.is_empty() or size.x < 100.0:
		return
	var center := Vector2(size.x * 0.5, size.y * 0.49)
	var radius := minf(size.x, size.y) * 0.36
	for index in range(cabins.size()):
		var angle := wheel_angle + TAU * float(index) / float(cabins.size()) - PI * 0.5
		var cabin := cabins[index]
		cabin.position = center + Vector2(cos(angle), sin(angle)) * radius - cabin.size * 0.5


func _draw() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.49)
	var radius := minf(size.x, size.y) * 0.36
	draw_circle(center, radius + 8.0, Color("#00b1c1"))
	draw_circle(center, radius, Color("#fddf03"))
	draw_arc(center, radius, 0.0, TAU, 96, Color("#fe005d"), 7.0, true)
	for index in range(CABINS.size()):
		var angle := wheel_angle + TAU * float(index) / float(CABINS.size()) - PI * 0.5
		var end := center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, end, Color("#0184bacc"), 3.0, true)
	draw_circle(center, 23.0, Color("#fe005d"))
	draw_line(center + Vector2(-28, 22), center + Vector2(-105, radius + 70), Color("#26384a"), 13.0, true)
	draw_line(center + Vector2(28, 22), center + Vector2(105, radius + 70), Color("#26384a"), 13.0, true)


func _on_glyph_pressed() -> void:
	alphabet_touched.emit()
