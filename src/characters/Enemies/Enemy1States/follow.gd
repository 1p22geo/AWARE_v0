extends State
class_name followState

@onready var movement_component: MovementComponent = $"../../../MovementComponent"

@export var speed: float = 8

var enemy : CharacterBody3D
var player : CharacterBody3D

func Enter():
	player = get_tree().get_first_node_in_group("Player")

func Physics_Update(_delta: float):
	var direction = (player.global_position - enemy.global_position).normalized()
