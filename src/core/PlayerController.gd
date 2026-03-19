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

const VOID_Y_THRESHOLD := -10.0
const VOID_DAMAGE := 25.0

func _physics_process(delta):
	if body == null or camera == null or movement == null:
		return

	# Handle void damage
	if body.global_position.y < VOID_Y_THRESHOLD:
		var health = body.get_node_or_null("HealthComponent") as Node
		var comp_mgr = body.get_node_or_null("ComponentManager")
		var armor = 0.0
		if comp_mgr and comp_mgr.has_method("get_total_armor"):
			armor = comp_mgr.get_total_armor()
		if health and health.has_method("take_damage"):
			health.take_damage(VOID_DAMAGE, armor)
			# Teleport back above the platform
			body.global_position = Vector3(0, 5, 0)
			body.velocity = Vector3.ZERO

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
		var target_angle = atan2(direction.x, direction.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_angle, 0.2)

	movement.move_direction = direction
	movement.move(body, delta)
