extends State
class_name wanderState

@onready var movement_component: MovementComponent = $"../../../MovementComponent"

@export var speed : float = 1
@export var enemy : CharacterBody3D

var move_direction := Vector3.ZERO
var wander_time : float

func wander():
	wander_time = randf_range(1,3)
	move_direction = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
	movement_component.move_direction = move_direction

func Enter():
	wander()
	movement_component.speed = speed
	

func Update(_delta: float):
	if wander_time > 0:
		wander_time -= _delta
	else:
		wander()

func Physics_Update(_delta: float):
	movement_component.move(enemy,_delta)
