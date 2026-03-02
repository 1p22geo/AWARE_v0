extends State
class_name IdleState

@onready var movement_component: MovementComponent = $"../../../MovementComponent"

func Enter():
	await get_tree().create_timer(0.5).timeout
	Change.emit(self,"wanderState")
