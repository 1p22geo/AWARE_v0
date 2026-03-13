extends State
class_name IdleState

@onready var movement: MovementController = %MovementController

func Enter():
	await get_tree().create_timer(0.5).timeout
	Change.emit(self,"wanderState")
