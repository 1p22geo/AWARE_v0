extends State
class_name wanderState

@onready var movement_component: MovementComponent = get_parent().get_parent().get_parent().get_node("MovementComponent") as MovementComponent

@export var speed : float = 1
var enemy : CharacterBody3D


var move_direction := Vector3.ZERO
var wander_time : float

func wander():
	wander_time = randf_range(1,3)
	move_direction = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
	if movement_component:
		movement_component.move_direction = move_direction

func Enter():
	enemy = get_parent().get_parent().get_parent() as CharacterBody3D
	if not movement_component:
		return
	wander()
	movement_component.speed = speed


func Update(_delta: float):
	if not movement_component:
		return
		
	# Sprawdź czy gracz jest w zasięgu widzenia
	var player_group = get_tree().get_first_node_in_group("Player")
	if player_group:
		var player = player_group.get_node("Player") as CharacterBody3D
		if player and is_instance_valid(player) and enemy.global_position.distance_to(player.global_position) < 15.0:
			Change.emit(self, "follow")
			return

	if wander_time > 0:
		wander_time -= _delta
	else:
		Change.emit(self,"IdleState")

func Physics_Update(_delta: float):
	if not movement_component or not enemy:
		return
	movement_component.move(enemy, _delta)
