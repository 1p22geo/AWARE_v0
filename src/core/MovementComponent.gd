extends Node
class_name MovementComponent

@export var speed := 5.0
@export var acceleration := 10.0
@export var rotation_speed := 30.0
@export var gravity := 55.0
@export var jump_height := 0.0 # Vertical impulse
@export var max_jumps := 1
@export var jump_disabled := false
@export var animation_player: AnimationPlayer

var move_direction := Vector3.ZERO
var look_target := Vector3.ZERO
var velocity := Vector3.ZERO
var is_jumping := false
var current_jumps := 0


func jump() -> void:
	if jump_disabled or jump_height <= 0:
		return
		
	if current_jumps < max_jumps:
		is_jumping = true
		current_jumps += 1
		if animation_player and animation_player.has_animation("jump"):
			animation_player.play("jump")


func move(body: CharacterBody3D, delta: float):
	# Gravity
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
	else:
		body.velocity.y = 0
		current_jumps = 0 # Reset jump count on floor
		
	# Jumping - now driven by the is_jumping flag.
	if is_jumping:
		body.velocity.y = jump_height
		is_jumping = false
		
	# Movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
		velocity = velocity.lerp(move_direction * speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, acceleration * delta)

	body.velocity.x = velocity.x
	body.velocity.z = velocity.z
	body.move_and_slide()
	
	_update_animations(body)

func _update_animations(body: CharacterBody3D) -> void:
	if not animation_player:
		return
		
	if not body.is_on_floor():
		# If we are in the air and not playing jump, we could play a fall/jump animation
		# but since 'jump' was triggered in jump(), we might want to let it finish 
		# or loop if it's a long fall. For now, jump() handles the trigger.
		pass
	else:
		# On floor
		if velocity.length() > 0.1:
			if animation_player.has_animation("walking"):
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
		else:
			if animation_player.has_animation("idle"):
				if animation_player.current_animation != "idle":
					animation_player.play("idle")
