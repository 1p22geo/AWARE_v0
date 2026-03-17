extends Node
class_name MovementComponent

@export var speed := 12.0
@export var acceleration := 10.0
@export var rotation_speed := 30.0
@export var gravity := 40.0
@export var jump_height := 23.0

var move_direction := Vector3.ZERO
var look_target := Vector3.ZERO
var velocity := Vector3.ZERO


func move(body: CharacterBody3D, delta: float):
	# rotation towards mouse
	var target_rot = atan2(
		body.global_position.x - look_target.x,
		body.global_position.z - look_target.z
	)
	
	body.rotation.y = lerp_angle(
		body.rotation.y,
		target_rot,
		rotation_speed * delta
	)
	
	# gravity
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
	else:
		body.velocity.y = 0
		
	# TODO: jumping
	if body.is_on_floor() and Input.is_action_just_pressed("jump"):
		body.velocity.y = jump_height
		
	# player movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
		velocity = velocity.lerp(move_direction * speed, acceleration * delta)

	else:
		velocity = velocity.lerp(Vector3.ZERO, acceleration * delta)

	body.velocity.x = velocity.x
	body.velocity.z = velocity.z
	body.move_and_slide()
