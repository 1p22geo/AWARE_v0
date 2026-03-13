extends State
class_name IdleState


func Enter():
	await get_tree().create_timer(0.5).timeout
	print(2)
	Change.emit(self,"wanderState")
