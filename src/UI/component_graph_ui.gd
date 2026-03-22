extends GraphEdit
class_name ComponentGraphUI

signal graph_updated(nodes: Dictionary, connections: Array)

var nodes_data: Dictionary = {} # ID: { "data": ComponentData }

func _ready() -> void:
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	delete_nodes_request.connect(_on_delete_nodes_request)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ComponentData

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is ComponentData:
		var graph_pos = (at_position + scroll_offset) / zoom
		add_component(data, graph_pos)

func add_component(comp_resource: ComponentData, pos: Vector2) -> void:
	var node = GraphNode.new()
	var id = str(Time.get_ticks_msec()) + "_" + str(randi() % 1000)
	node.name = id
	node.title = comp_resource.name
	node.position_offset = pos
	
	# to nie działa na starszej wersji
	if "show_close" in node:
		node.set("show_close", true)
	elif "show_close_button" in node:
		node.set("show_close_button", true)
	
	var comp_instance = comp_resource.duplicate()
	nodes_data[id] = { "data": comp_instance }
	
	var label = Label.new()
	label.text = "Cost: " + str(comp_instance.power_cost)
	node.add_child(label)
	
	if node.has_method("set_slot"):
		node.set_slot(0, true, 0, Color.AQUA, true, 0, Color.AQUA)
	
	if node.has_signal("close_request"):
		node.close_request.connect(_on_node_close.bind(id))
	elif node.has_signal("delete_request"):
		node.delete_request.connect(_on_node_close.bind(id))
		
	node.dragged.connect(func(_from, _to): _emit_update())
	
	add_child(node)
	_emit_update()

func _on_node_close(id: String) -> void:
	var node = get_node(id)
	if node:
		var to_remove = []
		for c in get_connection_list():
			if c.from_node == id or c.to_node == id:
				to_remove.append(c)
		for c in to_remove:
			disconnect_node(c.from_node, c.from_port, c.to_node, c.to_port)
			
		node.queue_free()
		nodes_data.erase(id)
		_emit_update()

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == to_node: return
	
	for c in get_connection_list():
		if c.from_node == from_node and c.to_node == to_node: return
		if c.from_node == to_node and c.to_node == from_node: return
		
	connect_node(from_node, from_port, to_node, to_port)
	_emit_update()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	_emit_update()

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		_on_node_close(node_name)

func highlight_connections(indices: Array) -> void:
	var connections = get_connection_list()
	for i in range(connections.size()):
		var c = connections[i]
		if i in indices:
			set_connection_activity(c.from_node, c.from_port, c.to_node, c.to_port, 1.0)
		else:
			set_connection_activity(c.from_node, c.from_port, c.to_node, c.to_port, 0.0)

func _emit_update() -> void:
	var connections = []
	for c in get_connection_list():
		connections.append({
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
			
	graph_updated.emit(exported_nodes, connections)

func get_graph_data() -> Dictionary:
	var connections = []
	for c in get_connection_list():
		connections.append({
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
	return { "nodes": exported_nodes, "connections": connections }
