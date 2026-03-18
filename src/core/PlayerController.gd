extends Node
class_name PlayerController

@export var body: CharacterBody3D
@export var camera: Camera3D

@onready var movement: MovementComponent = $"../MovementComponent"

func _unhandled_input(event: InputEvent) -> void:
	if not camera or not body:
		return
		
	if event is InputEventMouseMotion:
		var ray_length = 1000
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		
		var space_state = body.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			movement.look_target = result.position

func _physics_process(delta):
	if body == null or camera == null or movement == null:
		return

	# Handle jump input
	if Input.is_action_just_pressed("jump"):
		movement.jump()

	# Handle movement input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := Vector3.ZERO
	if input_dir.length() > 0:
		var basis := camera.global_transform.basis
		direction += input_dir.x * basis.x
		direction += input_dir.y * basis.z
		direction = direction.normalized()

	movement.move_direction = direction
	movement.move(body, delta)
