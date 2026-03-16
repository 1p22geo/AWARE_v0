extends Node
class_name PlayerController

@export var body: CharacterBody3D
@export var camera: Camera3D

@onready var movement: MovementComponent = $"../MovementComponent"

const RAY_LENGTH = 1000.0 

func get_mouse_world_position() -> Vector3:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var camera = viewport.get_camera_3d()
	if not camera:
		return Vector3.ZERO
		
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	
	var space_state = body.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	query.exclude = [body.get_rid()] 
	
	var result = space_state.intersect_ray(query)
	if result:
		return result["position"] 
	return Vector3.ZERO


func _physics_process(delta):
	if body == null or camera == null:
		return

	var input := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	)

	var direction := Vector3.ZERO

	if input.length() > 0:
		var basis = camera.global_transform.basis
		var right = basis.x
		var forward = -basis.z

		direction = (right * input.x + forward * input.y)
		direction.y = 0

	movement.move_direction = direction
	movement.look_target = get_mouse_world_position()
	movement.move(body, delta)
