extends State
class_name wanderState

@onready var movement_component: MovementComponent = $"../../../MovementComponent" as MovementComponent

@export var speed : float = 1
var enemy : CharacterBody3D


var move_direction := Vector3.ZERO
var wander_time : float

func wander():
	wander_time = randf_range(1,3)
	move_direction = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
	movement_component.move_direction = move_direction

func Enter():
	wander()
	movement_component.speed = speed
	enemy = get_tree().get_first_node_in_group("Enemy")
	

func Update(_delta: float):
	# Sprawdź czy gracz jest w zasięgu widzenia
	var player = get_tree().get_first_node_in_group("Player").get_child(0)
	if player and enemy.global_position.distance_to(player.global_position) < 15.0:
		Change.emit(self, "follow")
		return

	if wander_time > 0:
		wander_time -= _delta
	else:
		Change.emit(self,"IdleState")

func Physics_Update(_delta: float):
	movement_component.move(enemy,_delta)
