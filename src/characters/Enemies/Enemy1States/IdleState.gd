extends State
class_name IdleState

var idle_time : float


func Enter():
	idle_time = randf_range(1, 2)

func Update(_delta: float):
	if idle_time > 0:
		idle_time -= _delta
	else:
		Change.emit(self, "wanderState")
