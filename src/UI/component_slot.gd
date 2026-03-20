extends PanelContainer
class_name ComponentDataSlot

signal component_changed(component: ComponentData)

var component: ComponentData = null

@onready var label: Label = $Label

func _ready() -> void:
	_update_display()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ComponentData

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	set_component(data as ComponentData)

func set_component(comp: ComponentData) -> void:
	component = comp
	_update_display()
	component_changed.emit(component)

func clear() -> void:
	component = null
	_update_display()
	component_changed.emit(null)

func _update_display() -> void:
	if not is_inside_tree():
		return
	if component:
		label.text = component.name
	else:
		label.text = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	if component == null:
		return null
	var preview := Label.new()
	preview.text = component.name
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	var comp: ComponentData = component
	clear()
	return comp
