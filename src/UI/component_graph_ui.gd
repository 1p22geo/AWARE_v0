extends GraphEdit
class_name ComponentGraphUI

signal graph_updated(nodes: Dictionary, connections: Array)
signal component_removed(component: ComponentData)

var nodes_data: Dictionary = {} # ID: { "data": ComponentData }

const DELETE_KEYS := [KEY_DELETE, KEY_BACKSPACE]

func _ready() -> void:
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	delete_nodes_request.connect(_on_delete_nodes_request)
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in DELETE_KEYS:
			var selected := _get_selected_graph_nodes()
			if selected.size() > 0:
				_on_delete_nodes_request(selected)
				accept_event()

func _get_selected_graph_nodes() -> Array[StringName]:
	var out: Array[StringName] = []
	for ch in get_children():
		if ch is GraphNode and ch.selected:
			out.append(ch.name)
	return out

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ComponentData

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is ComponentData:
		# Convert local mouse position to graph space
		# Graph space = (local_pos + scroll_offset) / zoom
		var graph_pos = (at_position + scroll_offset) / zoom
		add_component(data, graph_pos)

func add_component(comp_resource: ComponentData, pos: Vector2) -> void:
	var node = GraphNode.new()
	var id = str(Time.get_ticks_msec()) + "_" + str(randi() % 1000)
	node.name = id
	node.title = comp_resource.name
	node.position_offset = pos
	
	# Defensive property setting for Godot 4 variations
	if "show_close" in node:
		node.set("show_close", true)
	elif "show_close_button" in node:
		node.set("show_close_button", true)
	
	# Duplicate resource so each instance is unique
	var comp_instance = comp_resource.duplicate()
	nodes_data[id] = { "data": comp_instance }
	
	_build_node_ui(node, comp_instance)
	
	# Add slots (input and output) using the unified set_slot method
	# Some versions use different signatures, so we try the most common ones
	if node.has_method("set_slot"):
		# Single unified port row. Keep simple but readable.
		node.set_slot(0, true, 0, Color(0.2, 0.95, 1.0), true, 0, Color(0.2, 0.95, 1.0))
	
	# Defensive signal connection
	if node.has_signal("close_request"):
		node.close_request.connect(_on_node_close.bind(id))
	elif node.has_signal("delete_request"):
		node.delete_request.connect(_on_node_close.bind(id))
		
	node.dragged.connect(func(_from, _to): _emit_update())
	
	add_child(node)
	_emit_update()

func _on_node_close(
	id: String
) -> void:
	var node = get_node_or_null(id)
	if node != null:
		var removed_comp: ComponentData = null
		if nodes_data.has(id) and nodes_data[id].has("data"):
			removed_comp = nodes_data[id].data as ComponentData
		if removed_comp != null:
			component_removed.emit(removed_comp)
		
		# Remove connections
		var to_remove = []
		for c in get_connection_list():
			if c.from_node == id or c.to_node == id:
				to_remove.append(c)
		for c in to_remove:
			disconnect_node(c.from_node, c.from_port, c.to_node, c.to_port)
			
		node.queue_free()
		nodes_data.erase(id)
		_emit_update()

func _on_connection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	# Prevent self-connection
	if from_node == to_node:
		return
	
	# Nodes must exist
	var from_path := NodePath(String(from_node))
	var to_path := NodePath(String(to_node))
	if get_node_or_null(from_path) == null:
		return
	if get_node_or_null(to_path) == null:
		return
	
	# Check if already connected
	for c in get_connection_list():
		if c.from_node == from_node and c.to_node == to_node:
			return
		if c.from_node == to_node and c.to_node == from_node:
			return
		# Prevent parallel duplicate cables between same ports
		if c.from_node == from_node and c.from_port == from_port \
				and c.to_node == to_node and c.to_port == to_port:
			return
		
	connect_node(from_node, from_port, to_node, to_port)
	_emit_update()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	_emit_update()

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		_on_node_close(node_name)

func _build_node_ui(node: GraphNode, comp: ComponentData) -> void:
	# Clear any existing children (defensive)
	for ch in node.get_children():
		if ch is Control:
			ch.queue_free()
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 2)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var cost := Label.new()
	cost.text = "Cost: " + str(comp.power_cost)
	cost.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95, 0.9))
	root.add_child(cost)

	var stats := _key_stats_lines(comp)
	if stats.size() > 0:
		var s := Label.new()
		s.text = "\n".join(stats)
		s.add_theme_font_size_override("font_size", 12)
		s.add_theme_color_override("font_color", Color(0.9, 0.95, 1, 0.85))
		root.add_child(s)

	node.add_child(root)

func _key_stats_lines(comp: ComponentData) -> Array[String]:
	var out: Array[String] = []
	if comp.hp != 0.0: out.append("HP +" + str(comp.hp))
	if comp.armor != 0.0: out.append("Armor +" + str(comp.armor))
	if comp.speed != 0.0: out.append("Speed " + str(comp.speed))
	if comp.damage != 0.0: out.append("Damage +" + str(comp.damage))
	if comp.energy_regen != 0.0: out.append("EnergyRegen +" + str(comp.energy_regen))
	if comp.overheat_limit != 0.0: out.append("HeatLimit " + str(comp.overheat_limit))
	return out

func highlight_connections(indices: Array) -> void:
	var conn_list = get_connection_list()
	for i in range(conn_list.size()):
		var c = conn_list[i]
		if i in indices:
			# Highlight synergized connection
			set_connection_activity(c.from_node, c.from_port, c.to_node, c.to_port, 1.0)
		else:
			set_connection_activity(c.from_node, c.from_port, c.to_node, c.to_port, 0.0)

func _emit_update() -> void:
	var conn_list = []
	for c in get_connection_list():
		conn_list.append({
			"from": str(c.from_node),
			"to": str(c.to_node)
		})
	
	var exported_nodes = {}
	for id in nodes_data:
		var node = get_node(id)
		if node:
			exported_nodes[id] = {
				"data": nodes_data[id].data,
				"position": node.position_offset
			}
			
	graph_updated.emit(exported_nodes, conn_list)

func get_graph_data() -> Dictionary:
	var conn_list = []
	for c in get_connection_list():
		conn_list.append({
			"from": str(c.from_node),
			"to": str(c.to_node)
		})
	
	var exported_nodes = {}
	for id in nodes_data:
		var node = get_node(id)
		if node:
			exported_nodes[id] = {
				"data": nodes_data[id].data,
				"position": node.position_offset
			}
	return { "nodes": exported_nodes, "connections": conn_list }
