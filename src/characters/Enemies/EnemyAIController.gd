extends Node
class_name EnemyAIController

@export var body: CharacterBody3D
@onready var movement: MovementComponent = $"../MovementComponent" as MovementComponent

var player: CharacterBody3D

func _ready():
	# A simple way to find the player. You might want a more robust solution.
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player = player_nodes[0]

