extends CanvasLayer

signal restart_requested

@onready var death_label: Label = $CenterContainer/VBox/DeathLabel
@onready var press_any_key: Label = $CenterContainer/VBox/PressAnyKey

var fall_duration := 1.8
var fall_delay := 0.5
var screen_height: float = DisplayServer.window_get_size().y

var _base_x: float

func _ready() -> void:
	death_label.position.y = -200
	death_label.modulate.a = 0
	press_any_key.modulate.a = 0
	press_any_key.scale = Vector2(0.8, 0.8)

func show_death() -> void:
	visible = true
	_start_fall_animation()

func _start_fall_animation() -> void:
	_base_x = death_label.position.x

	# Initial fade in
	var t1 := create_tween()
	t1.tween_interval(fall_delay)
	t1.tween_property(death_label, "modulate:a", 1.0, 0.3)

	# Fall animation
	var t2 := create_tween()
	t2.tween_interval(fall_delay)
	t2.tween_property(death_label, "position:y", screen_height * 0.35, fall_duration)
	t2.tween_callback(_on_land)

	# Shake during fall - use a looping animation instead
	var t3 := create_tween()
	t3.set_loops(int(fall_duration / 0.05))
	var elapsed := 0.0
	t3.tween_interval(0.05)
	t3.tween_callback(func():
		var offset = randf_range(-4, 4)
		death_label.position.x = _base_x + offset
	)

func _on_land() -> void:
	death_label.position.x = _base_x

	# Show hint
	var t := create_tween()
	t.tween_property(press_any_key, "modulate:a", 1.0, 0.4)
	t.parallel().tween_property(press_any_key, "scale", Vector2(1.0, 1.0), 0.3)
	t.tween_callback(func(): set_process_input(true))

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_pressed() and not event.is_echo():
		_fall_out()

func _fall_out() -> void:
	set_process_input(false)

	var t := create_tween()
	t.set_parallel(true)

	t.tween_property(death_label, "position:y", screen_height + 500, 1.2)
	t.tween_property(death_label, "modulate:a", 0.0, 0.8)
	t.tween_property(press_any_key, "position:y", screen_height + 300, 0.9)
	t.tween_property(press_any_key, "modulate:a", 0.0, 0.6)

	await t
	restart_requested.emit()
