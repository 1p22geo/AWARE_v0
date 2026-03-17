extends Button
class_name ComponentItem

@export var component_data: ComponentData

func _get_drag_data(_at_position: Vector2) -> Variant:
	if component_data == null:
		return null
	var preview := Label.new()
	preview.text = component_data.name
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	return component_data
