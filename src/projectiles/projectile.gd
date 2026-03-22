extends Area3D
class_name Projectile

signal hit_target(target: Node3D)

@export var speed: float = 30.0
@export var damage: float = 25.0
@export var lifetime: float = 5.0

var direction: Vector3 = Vector3.ZERO
var target: Vector3 = Vector3.ZERO
var traveled_distance: float = 0.0
var max_distance: float = 100.0
var has_hit: bool = false

func initialize(src: Vector3, dest: Vector3) -> void:
	global_position = src
	direction = (dest - src).normalized()
	target = dest
	look_at(dest, Vector3.UP)

func _physics_process(delta: float) -> void:
	var movement = direction * speed * delta
	global_position += movement
	traveled_distance += movement.length()

	if traveled_distance >= max_distance:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if has_hit:
		return
	has_hit = true
	
	# Try to deal damage - check body first, then children (for EnemyController pattern)
	var damaged = false
	if body.has_method("take_damage"):
		body.take_damage(damage)
		damaged = true
	else:
		for child in body.get_children():
			if child.has_method("take_damage"):
				child.take_damage(damage)
				damaged = true
				break
	if damaged:
		hit_target.emit(body)
	queue_free()
