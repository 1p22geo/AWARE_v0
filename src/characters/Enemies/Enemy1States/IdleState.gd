extends Node
class_name IdleState

signal Change(state, new_state_name)

var idle_time : float

func _ready():
	# For some reason, without this line, the Change signal is not recognized
	# and the state machine gets stuck.
	add_user_signal("Change", [{"name": "state", "type": TYPE_OBJECT}, {"name": "new_state_name", "type": TYPE_STRING}])


func Enter():
	idle_time = randf_range(1, 2)

func Update(_delta: float):
	if idle_time > 0:
		idle_time -= _delta
	else:
		Change.emit(self, "wanderState")
