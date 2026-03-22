extends Node
class_name MovementComponent

@export var speed := 5.0
@export var acceleration := 10.0
@export var rotation_speed := 30.0
@export var gravity := 55.0
@export var jump_height := 0.0 # Vertical impulse
@export var max_jumps := 0
@export var jump_disabled := false
@export var animation_player: AnimationPlayer

var move_direction := Vector3.ZERO
var look_target := Vector3.ZERO
var velocity := Vector3.ZERO
var is_jumping := false
var current_jumps := 0
var was_on_floor := true


func jump() -> void:
	if jump_disabled or jump_height <= 0:
		return
		
	if current_jumps < max_jumps:
		is_jumping = true
		current_jumps += 1
		if animation_player and animation_player.has_animation("jump"):
			animation_player.play("jump")


func move(body: CharacterBody3D, delta: float):
	var is_on_floor = body.is_on_floor()
	
	# Gravity
	if not is_on_floor or is_jumping:
		body.velocity.y -= gravity * delta
	else:
		body.velocity.y = 0
		current_jumps = 0 # Reset jump count on floor
		
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
	
	_update_animations(body, is_on_floor)
	was_on_floor = is_on_floor

func _update_animations(body: CharacterBody3D, is_on_floor: bool) -> void:
	if not animation_player:
		return
		
	if not is_on_floor:
		if animation_player.current_animation == "jump":
			var anim = animation_player.get_animation("jump")
			# bruh
			if animation_player.current_animation_position > anim.length * 0.5:
				animation_player.pause()
	else:
		if not was_on_floor:
			if animation_player.current_animation == "jump":
				animation_player.play()
				return 
		
		if animation_player.current_animation == "jump" and animation_player.is_playing():
			return

		if velocity.length() > 0.1:
			if animation_player.has_animation("walking"):
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
		else:
			if animation_player.has_animation("idle"):
				if animation_player.current_animation != "idle":
					animation_player.play("idle")
