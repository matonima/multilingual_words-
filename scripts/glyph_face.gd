extends Control

var expression := 0
var eye_line := 0.34
var blink_amount := 0.0
var blink_timer := 2.0
var blink_elapsed := -1.0
var blink_duration := 0.16
var expression_timer := 3.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = int(Time.get_ticks_usec()) ^ int(get_instance_id())
	blink_timer = rng.randf_range(1.4, 4.8)
	expression_timer = rng.randf_range(2.2, 5.5)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(face_variant: int, line_position := 0.34) -> void:
	expression = posmod(face_variant, 5)
	eye_line = line_position
	queue_redraw()


func celebrate() -> void:
	expression = 1
	expression_timer = 2.0
	queue_redraw()


func _process(delta: float) -> void:
	if blink_elapsed < 0.0:
		blink_timer -= delta
		if blink_timer <= 0.0:
			blink_elapsed = 0.0
			blink_duration = rng.randf_range(0.13, 0.19)
	else:
		blink_elapsed += delta
		if blink_elapsed <= blink_duration:
			blink_amount = sin(PI * blink_elapsed / blink_duration)
		else:
			blink_amount = 0.0
			blink_elapsed = -1.0
			blink_timer = rng.randf_range(1.8, 5.8)
		queue_redraw()
	expression_timer -= delta
	if expression_timer <= 0.0:
		expression = posmod(expression + rng.randi_range(1, 4), 5)
		expression_timer = rng.randf_range(2.4, 6.2)
		queue_redraw()


func _draw() -> void:
	var center_x := size.x * 0.5
	var eye_y := size.y * eye_line
	var eye_gap := minf(size.x * 0.14, 24.0)
	var eye_radius := clampf(size.x * 0.055, 6.0, 12.0)
	var pupil_shift: Vector2 = [
		Vector2(-2, 1), Vector2(2, 0), Vector2(0, -2),
		Vector2(-1, 2), Vector2(2, 2)
	][expression]
	_draw_eye(Vector2(center_x - eye_gap, eye_y), eye_radius, pupil_shift)
	_draw_eye(Vector2(center_x + eye_gap, eye_y), eye_radius, pupil_shift)
	_draw_eyebrows(center_x, eye_y, eye_gap, eye_radius)
	_draw_mouth(center_x, size.y * 0.68)


func _draw_eye(position: Vector2, radius: float, pupil_shift: Vector2) -> void:
	var openness := maxf(0.07, 1.0 - blink_amount)
	draw_set_transform(position, 0.0, Vector2(1.0, openness))
	draw_circle(Vector2.ZERO, radius + 2.4, Color("#241916"))
	draw_circle(Vector2.ZERO, radius, Color("#fffdf5"))
	draw_circle(pupil_shift, radius * 0.47, Color("#241916"))
	draw_circle(pupil_shift + Vector2(-1.4, -1.7), radius * 0.13, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_eyebrows(center_x: float, eye_y: float, gap: float, radius: float) -> void:
	var brow_y := eye_y - radius - 6.0
	var tilt: float = [-2.0, 3.0, -5.0, 7.0, 1.0][expression]
	draw_line(Vector2(center_x - gap - radius, brow_y + tilt), Vector2(center_x - gap + radius, brow_y - tilt), Color("#211713"), 3.5, true)
	draw_line(Vector2(center_x + gap - radius, brow_y - tilt), Vector2(center_x + gap + radius, brow_y + tilt), Color("#211713"), 3.5, true)


func _draw_mouth(center_x: float, mouth_y: float) -> void:
	match expression:
		0, 1:
			draw_circle(Vector2(center_x, mouth_y), 13.0, Color("#251516"))
			draw_circle(Vector2(center_x, mouth_y + 2), 9.0, Color("#ff5994"))
		2:
			draw_circle(Vector2(center_x, mouth_y), 9.0, Color("#251516"))
		3:
			draw_arc(Vector2(center_x, mouth_y + 9), 15.0, PI + 0.2, TAU - 0.2, 20, Color("#211713"), 4.0, true)
		4:
			draw_arc(Vector2(center_x, mouth_y - 6), 17.0, 0.15, PI - 0.15, 20, Color("#211713"), 4.0, true)
