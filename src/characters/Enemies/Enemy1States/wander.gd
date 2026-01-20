extends State
class_name wander

@onready var walk_component: Node3D = $"../../WalkComponent"

@export var speed : float = 6

var move_direction := Vector3.ZERO
var wander_time : float

func wander():
	wander_time = randf_range(3,7)
	move_direction = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()

func Enter():
	wander()

func Update(_delta: float):
	if wander_time > 0:
		wander_time -= _delta
	else:
		wander()


func Physics_Update(_delta: float):
	walk_component.
