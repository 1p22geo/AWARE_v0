extends RigidBody3D
class_name Tile

func _ready():
	print("tile exists at " + str(global_position))
	input_event.connect(on_input_event)

func on_input_event(camera, event, click_position, click_normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		print("clicked" + str(global_position))
