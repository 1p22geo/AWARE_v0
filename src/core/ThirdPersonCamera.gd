extends Camera3D
class_name ThirdPersonCamera

@export var target: Node3D
@export var height := 12.0
@export var distance := 10.0
@export var smooth := 5.0

func _process(delta):
	if target == null:
		return

	var desired = target.global_position + Vector3(0, height, distance)
	global_position = global_position.lerp(desired, smooth * delta)
	look_at(target.global_position, Vector3.UP)
