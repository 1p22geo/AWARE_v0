extends State
class_name followState

@onready var movement_component: MovementComponent = $"../../../MovementComponent" as MovementComponent

@export var speed: float = 8


var enemy : CharacterBody3D
var player : CharacterBody3D

func Enter():
	player = get_tree().get_first_node_in_group("Player").get_child(0)
	enemy = get_tree().get_first_node_in_group("Enemy")


func Physics_Update(_delta: float):
	if not player or not is_instance_valid(player):
		Change.emit(self, "wanderState")
		return

	# Sprawdź czy gracz jest nadal widoczny
	if enemy.global_position.distance_to(player.global_position) > 15.0:
		Change.emit(self, "wanderState")
		return

	var direction = (player.global_position - enemy.global_position).normalized()
	movement_component.move_direction = direction
	movement_component.speed = speed
	movement_component.move(enemy, _delta)
