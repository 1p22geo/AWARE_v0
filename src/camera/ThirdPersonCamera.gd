extends Camera3D
class_name ThirdPersonCamera

@export var target: Node3D
@export var default_offset := Vector3(0, 12, 10)
@export var map_offset := Vector3(0, 100, 80)
@export var follow_speed := 4.0
@export var zoom_speed := 5.0

var smoothed_position := Vector3.ZERO
var current_offset := Vector3.ZERO
var is_map_view := false

func _ready():
	if target == null:
		target = get_tree().current_scene.find_child("Player", true, false)
	if target:
		smoothed_position = target.global_position
	current_offset = default_offset

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_map"):
		is_map_view = !is_map_view
	
	if not target:
		return

	var target_destination = map_offset if is_map_view else default_offset
	current_offset = current_offset.lerp(target_destination, zoom_speed * delta)
	
	smoothed_position = smoothed_position.lerp(target.global_position, follow_speed * delta)
	global_position = smoothed_position + current_offset
	
	look_at(smoothed_position + Vector3(0, 1, 0), Vector3.UP)
