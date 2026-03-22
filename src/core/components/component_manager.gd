extends Node
class_name ComponentManager

@load("res://src/core/components/component.gd") var ComponentData
signal component_acquired(component: ComponentData)

@export var player_body: CharacterBody3D
@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var max_power := 100.0

# Predefined synergies
@export var synergies: Array[SynergyData] = []

var equipped_nodes: Dictionary = {} # ID: { "data": ComponentData, "position": Vector2 }
var connections: Array = [] # [ { "from": ID, "to": ID } ]
var total_power_cost: float = 0.0
var total_armor: float = 0.0

func _ready() -> void:
	print("ComponentManager _ready called.")
	component_acquired.connect(
		func(component: Resource):
			print("Component acquired signal connected to NotificationUI. Showing notification for: ", component.name)
			# Access the Control node within the NotificationUI scene
			var notification_control = NotificationUI.get_node("Control")
			if notification_control and notification_control.has_method("show_notification"):
				notification_control.show_notification("New Component Acquired: " + component.name)
			else:
				push_warning("NotificationUI Control node or show_notification method not found.")
	)
	_find_ui_and_connect.call_deferred()
	
	if health_component:
		health_component.health_change.connect(_on_health_changed)

func _find_ui_and_connect() -> void:
	print("ComponentManager _find_ui_and_connect called.")
	var ui = get_tree().get_first_node_in_group("UI")
	if not ui:
		ui = get_tree().root.find_child("Ui", true, false)
		
	if ui:
		print("UI node found: ", ui.name)
		if ui.has_method("add_component_to_inventory"):
			print("UI has add_component_to_inventory method. Connecting signal.")
			component_acquired.connect(ui.add_component_to_inventory)
		else:
			print("UI DOES NOT have add_component_to_inventory method.")

		if ui.has_signal("components_updated"):
			ui.components_updated.connect(_on_components_updated)
		
		# For the graph-based UI, we expect a slightly different update
		if ui.has_signal("graph_updated"):
			ui.graph_updated.connect(_on_graph_updated)
			
		if ui.has_method("get_graph_data"):
			var data = ui.get_graph_data()
			_on_graph_updated(data.nodes, data.connections)
	else:
		push_warning("ComponentManager: UI not found during initialization.")

func _on_health_changed(hp: float, max_hp: float) -> void:
	var ui = get_tree().get_first_node_in_group("UI")
	if not ui: ui = get_tree().root.find_child("Ui", true, false)
	if ui:
		ui.update_health(hp, max_hp)

func _on_components_updated(_components: Array[ComponentData]) -> void:
	# Deprecated, use _on_graph_updated
	pass

func _on_graph_updated(nodes: Dictionary, conn: Array) -> void:
	equipped_nodes = nodes
	connections = conn
	apply_stats()

func apply_stats() -> void:
	if not is_inside_tree(): return
	
	# Base stats
	var total_hp := 50.0 
	var total_speed := 5.0 
	var total_jump_height := 0.0 
	var total_jump_count := 1
	var total_regen := 0.0
	var calculated_armor := 0.0
	var total_damage := 0.0
	var current_power := 0.0
	var jump_disabled := false
	
	# Node stats
	for id in equipped_nodes:
		var comp: ComponentData = equipped_nodes[id].data
		if not comp.is_active: continue
		total_hp += comp.hp
		total_speed += comp.speed
		total_jump_height += comp.dash_power 
		total_jump_count += comp.jump_count
		total_regen += comp.energy_regen
		calculated_armor += comp.armor
		total_damage += comp.damage
		current_power += comp.power_cost
		
	# Synergy stats & link costs
	var active_synergies_details: Array[Dictionary] = []
	var synergized_connections: Array = []
	
	for i in range(connections.size()):
		var conn = connections[i]
		var node_a = equipped_nodes[conn.from].data
		var node_b = equipped_nodes[conn.to].data
		
		# Link cost
		current_power += 2.0 # Default link cost
		
		# Find synergy
		for syn in synergies:
			if (syn.component_a == node_a.name and syn.component_b == node_b.name) or \
			   (syn.component_a == node_b.name and syn.component_b == node_a.name):
				total_hp += syn.hp_bonus
				total_speed += syn.speed_bonus
				calculated_armor += syn.armor_bonus
				total_damage += syn.damage_bonus
				total_regen += syn.energy_regen_bonus
				total_jump_height += syn.dash_power_bonus
				total_jump_count += syn.jump_count_bonus
				if syn.jump_disabled: jump_disabled = true
				
				total_hp *= syn.hp_mult
				total_speed *= syn.speed_mult
				calculated_armor *= syn.armor_mult
				total_damage *= syn.damage_mult
				
				active_synergies_details.append({
					"name": syn.name,
					"hp": syn.hp_bonus,
					"speed": syn.speed_bonus,
					"damage": syn.damage_bonus,
					"power": syn.link_power_cost
				})
				synergized_connections.append(i)
				
				# Increase power cost for synergy links
				current_power += syn.link_power_cost - 2.0
				break
	
	total_power_cost = current_power
	self.total_armor = calculated_armor

	if health_component:
		var old_max = health_component.MAX_HEALTH
		var old_hp = health_component.health
		var ratio = old_hp / old_max if old_max > 0 else 1.0
		
		health_component.MAX_HEALTH = total_hp
		health_component.regen_rate = total_regen
		health_component.health = total_hp * ratio
		_on_health_changed(health_component.health, health_component.MAX_HEALTH)
		
	if movement_component:
		movement_component.speed = total_speed
		movement_component.jump_height = total_jump_height
		movement_component.max_jumps = total_jump_count
		movement_component.jump_disabled = jump_disabled

	# Notify UI about total stats if needed
	var ui = get_tree().get_first_node_in_group("UI")
	if not ui: ui = get_tree().root.find_child("Ui", true, false)
	if ui and ui.has_method("update_total_bonuses"):
		ui.update_total_bonuses({
			"hp": total_hp,
			"speed": total_speed,
			"armor": calculated_armor,
			"damage": total_damage,
			"power_cost": total_power_cost,
			"max_power": max_power,
			"synergies": active_synergies_details,
			"synergized_connections": synergized_connections
		})

func get_total_armor() -> float:
	return total_armor

func acquire_component(component: Resource):
	print("Acquire component called for: ", component.name)
	emit_signal("component_acquired", component)
