extends Camera3D

@export var target: Node3D
@export var default_offset := Vector3(0, 12, 10)
@export var map_offset := Vector3(0, 80, 60)
@export var follow_speed := 4.0
@export var zoom_speed := 5.0

var smoothed_position := Vector3.ZERO
var current_offset := Vector3.ZERO
var is_map_view := false

func _ready():
	if target == null:
		target = get_tree().get_root().find_child("Player", true, false)
	if target:
		smoothed_position = target.global_position
	current_offset = default_offset

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_TAB:
			is_map_view = !is_map_view
			print("KLIKNIETO TAB! Widok mapy: ", is_map_view)
		
		# Testowy print, żeby sprawdzić czy jakikolwiek klawisz działa
		if event.pressed:
			print("Nacisnieto klawisz o kodzie: ", event.keycode)

func _physics_process(delta):
	if not target:
		return

	var target_offset = map_offset if is_map_view else default_offset
	current_offset = current_offset.lerp(target_offset, zoom_speed * delta)
	
	smoothed_position = smoothed_position.lerp(target.global_position, follow_speed * delta)
	global_position = smoothed_position + current_offset
	
	look_at(smoothed_position + Vector3(0, 1, 0), Vector3.UP)
