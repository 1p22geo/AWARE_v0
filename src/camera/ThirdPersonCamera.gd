extends Camera3D
class_name ThirdPersonCamera

@export var target: Node3D
@export var default_offset := Vector3(10, 8, 10)
@export var map_offset := Vector3(0, 100, 80)
@export var follow_speed := 10.0 
@export var zoom_speed := 5.0
@export var collision_margin := 0.5
@export var look_ahead_distance := 0.0 

var smoothed_position := Vector3.ZERO
var is_map_view := false
var dynamic_look_offset := Vector3.ZERO

func _ready():
	if target == null:
		target = get_tree().current_scene.find_child("Player", true, false)
	if target:
		smoothed_position = target.global_position

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_map"):
		is_map_view = !is_map_view
	
	if not target:
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var target_look_offset = Vector3(input_dir.x, 0, input_dir.y) * look_ahead_distance
	
	dynamic_look_offset = dynamic_look_offset.lerp(target_look_offset, delta * 2.0)

	var base_offset = map_offset if is_map_view else default_offset
	
	smoothed_position = smoothed_position.lerp(target.global_position, follow_speed * delta)
	
	var target_pos_with_look = smoothed_position + base_offset + dynamic_look_offset
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(target.global_position + Vector3(0, 1.5, 0), target_pos_with_look)
	query.exclude = [target.get_rid()] 
	
	var result = space_state.intersect_ray(query)
	var final_pos = target_pos_with_look
	
	if result and not is_map_view:
		final_pos = result.position + result.normal * collision_margin
	
	global_position = global_position.lerp(final_pos, follow_speed * delta)
	
	look_at(smoothed_position + Vector3(0, 1.5, 0), Vector3.UP)
