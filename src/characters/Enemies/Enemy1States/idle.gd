extends State
class_name EnemyIdle

@onready var movement_component: MovementComponent = $"../../../MovementComponent"


@export var speed: float = 1
@export var enemy: CharacterBody3D


var move_direction := Vector3.ZERO
var wander_time : float

func randomize_wander():
	move_direction = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
	wander_time = randf_range(2,8)
	movement_component.move_direction = move_direction

func Enter():
	randomize_wander()
	movement_component.speed = speed

func Update(_delta: float):
	if wander_time > 0:
		wander_time -= _delta
	else:
		randomize_wander()

func Physics_Update(_delta: float):
	
	movement_component.move(enemy,_delta)
	
