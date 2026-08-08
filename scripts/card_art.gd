extends Control

var accent := Color("#00b1c1")
var variant := "language"


func setup(color: Color, art_variant: String) -> void:
	accent = color
	variant = art_variant
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if size.x < 20.0:
		return
	var pale := Color(accent.r, accent.g, accent.b, 0.12)
	var medium := Color(accent.r, accent.g, accent.b, 0.22)
	draw_circle(Vector2(size.x - 34.0, 30.0), 92.0, pale)
	draw_circle(Vector2(18.0, size.y - 15.0), 64.0, pale)
	for index in range(5):
		var dot := Vector2(size.x - 42.0 - index * 25.0, 28.0 + (index % 2) * 17.0)
		draw_circle(dot, 6.0 + float(index % 3), medium)
	if variant == "language":
		draw_line(Vector2(24, size.y - 27), Vector2(size.x - 24, size.y - 27), accent, 5.0, true)
		draw_arc(Vector2(size.x * 0.5, size.y + 26), size.x * 0.34, PI, TAU, 48, medium, 10.0, true)
	elif variant == "alphabet":
		for radius in [76.0, 94.0]:
			draw_arc(Vector2(size.x * 0.5, size.y * 0.46), radius, 0.15, PI - 0.15, 40, medium, 5.0, true)
	else:
		var y := size.y * 0.47
		draw_line(Vector2(size.x * 0.22, y), Vector2(size.x * 0.78, y), medium, 8.0, true)
		for x in [0.28, 0.5, 0.72]:
			draw_circle(Vector2(size.x * x, y), 14.0, accent)
