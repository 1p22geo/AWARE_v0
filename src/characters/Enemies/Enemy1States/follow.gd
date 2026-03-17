extends State
class_name followState

@onready var movement_component: MovementComponent = get_parent().get_parent().get_node("MovementComponent") as MovementComponent

@export var speed: float = 8


var enemy : CharacterBody3D
var player : CharacterBody3D

func Enter():
	enemy = get_parent().get_parent() as CharacterBody3D
	player = get_tree().get_first_node_in_group("Player")
	if not movement_component:
		return
	movement_component.speed = speed


func Update(_delta: float):
	if not player or not is_instance_valid(player) or not movement_component:
		Change.emit(self, "wanderState")
		return

	# Sprawdź czy gracz jest nadal widoczny
	if enemy.global_position.distance_to(player.global_position) > 15.0:
		Change.emit(self, "wanderState")
		return

	var direction = (player.global_position - enemy.global_position).normalized()
	movement_component.move_direction = direction

func Physics_Update(_delta: float):
	if not movement_component or not enemy:
		return
	movement_component.move(enemy, _delta)
