extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var overheat_container: HBoxContainer = %OverheatContainer
@onready var screen_clipper: Control = %ScreenClipper
@onready var screens_container: VBoxContainer = %ScreensContainer

var current_screen := 0
const TOTAL_SCREENS := 3
const ANIM_DURATION := 0.35
var is_animating := false

func _ready() -> void:
	_update_screen_sizes()
	screen_clipper.resized.connect(_update_screen_sizes)

func _update_screen_sizes() -> void:
	var h := screen_clipper.size.y
	var w := screen_clipper.size.x
	screens_container.size.x = w
	for child in screens_container.get_children():
		if child is Control:
			child.custom_minimum_size.y = h
	screens_container.position.y = -current_screen * h

func _input(event: InputEvent) -> void:
	if is_animating:
		return

	# Sprawdzamy przewijanie w dół (następny ekran)
	var is_scroll_down = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN
	var is_ui_down := event.is_action_pressed("ui_down")

	if is_scroll_down or is_ui_down:
		if current_screen < TOTAL_SCREENS - 1:
			_go_to_screen(current_screen + 1)
			get_viewport().set_input_as_handled()
		return # Kończymy przetwarzanie, by uniknąć konfliktów

	# Sprawdzamy przewijanie w górę (poprzedni ekran)
	var is_scroll_up = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP
	var is_ui_up := event.is_action_pressed("ui_up")

	if is_scroll_up or is_ui_up:
		if current_screen > 0:
			_go_to_screen(current_screen - 1)
			get_viewport().set_input_as_handled()

func _go_to_screen(index: int) -> void:
	current_screen = index
	is_animating = true
	var target_y := -current_screen * screen_clipper.size.y
	var tween := create_tween()
	tween.tween_property(screens_container, "position:y", target_y, ANIM_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): is_animating = false)

func update_health(current_hp: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func update_energy(current_energy: float, max_energy: float) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current_energy

func update_overheat(comp_name: String, current_heat: float, heat_limit: float) -> void:
	var existing: ProgressBar = null
	for child in overheat_container.get_children():
		if child.name == "OH_" + comp_name:
			existing = child as ProgressBar
			break
	if heat_limit <= 0.0:
		if existing:
			existing.queue_free()
		return
	if existing == null:
		existing = ProgressBar.new()
		existing.name = "OH_" + comp_name
		existing.custom_minimum_size = Vector2(60, 14)
		existing.show_percentage = false
		existing.rounded = true
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color(0.15, 0.15, 0.15, 1)
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.9, 0.5, 0.1, 1)
		existing.add_theme_stylebox_override("background", bg)
		existing.add_theme_stylebox_override("fill", fill)
		overheat_container.add_child(existing)
	existing.max_value = heat_limit
	existing.value = current_heat
