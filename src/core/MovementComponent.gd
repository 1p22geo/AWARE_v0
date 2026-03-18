extends Node
class_name MovementComponent

@export var speed := 5.0
@export var acceleration := 10.0
@export var rotation_speed := 30.0
@export var gravity := 55.0
@export var jump_height := 0.0 # Disabled by default

var move_direction := Vector3.ZERO
var look_target := Vector3.ZERO
var velocity := Vector3.ZERO
var is_jumping := false


func jump() -> void:
	# Only allow jumping if jump_height is set (by a component)
	if jump_height > 0:
		is_jumping = true


func move(body: CharacterBody3D, delta: float):
	# Only rotate if a look_target has been set.
	if look_target != Vector3.ZERO:
		var target_rot = atan2(
			body.global_position.x - look_target.x,
			body.global_position.z - look_target.z
		)
		
		body.rotation.y = lerp_angle(
			body.rotation.y,
			target_rot,
			rotation_speed * delta
		)
	
	# Gravity
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
	else:
		body.velocity.y = 0
		
	# Jumping - now driven by the is_jumping flag.
	if body.is_on_floor() and is_jumping:
		body.velocity.y = jump_height
		
	# Movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
		velocity = velocity.lerp(move_direction * speed, acceleration * delta)

	else:
		velocity = velocity.lerp(Vector3.ZERO, acceleration * delta)

	body.velocity.x = velocity.x
	body.velocity.z = velocity.z
	body.move_and_slide()

	is_jumping = false
