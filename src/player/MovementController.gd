extends Node
class_name MovementController

@export var speed := 6.0
@export var acceleration := 10.0
@export var rotation_speed := 10.0
@export var gravity := 25.0

var move_direction := Vector3.ZERO
var velocity := Vector3.ZERO

func move(body: CharacterBody3D, delta: float):
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
	else:
		body.velocity.y = 0

	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
		velocity = velocity.lerp(move_direction * speed, acceleration * delta)

		var target_rot = atan2(-velocity.x, -velocity.z)
		body.rotation.y = lerp_angle(
			body.rotation.y,
			target_rot,
			rotation_speed * delta
		)
	else:
		velocity = velocity.lerp(Vector3.ZERO, acceleration * delta)

	body.velocity.x = velocity.x
	body.velocity.z = velocity.z
	body.move_and_slide()
