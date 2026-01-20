extends Node
class_name PlayerController

@export var body: CharacterBody3D
@export var camera: Camera3D

@onready var movement: MovementComponent = $"../MovementComponent"

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
	movement.move(body, delta)
