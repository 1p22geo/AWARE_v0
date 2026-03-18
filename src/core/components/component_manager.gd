extends Node
class_name ComponentManager

@export var player_body: CharacterBody3D
@export var health_component: HealthComponent
@export var movement_component: MovementComponent

var equipped_components: Array[ComponentData] = []

func _ready() -> void:
	# Find UI and connect
	_find_ui_and_connect.call_deferred()
	
	if health_component:
		health_component.health_change.connect(_on_health_changed)

func _find_ui_and_connect() -> void:
	var ui = get_tree().get_first_node_in_group("UI")
	if not ui:
		ui = get_tree().root.find_child("Ui", true, false)
		
	if ui:
		if ui.has_signal("components_updated"):
			ui.components_updated.connect(_on_components_updated)
			
		if ui.has_method("get_equipped_components"):
			equipped_components = ui.get_equipped_components()
			apply_stats()
	else:
		push_warning("ComponentManager: UI not found during initialization.")

func _on_health_changed(hp: float, max_hp: float) -> void:
	var ui = get_tree().get_first_node_in_group("UI")
	if not ui: ui = get_tree().root.find_child("Ui", true, false)
	if ui:
		ui.update_health(hp, max_hp)

func _on_components_updated(components: Array[ComponentData]) -> void:
	equipped_components = components
	apply_stats()

func apply_stats() -> void:
	if not is_inside_tree(): return
	
	# Base stats
	var total_hp := 50.0 # Base health
	var total_speed := 5.0 
	var total_jump := 0.0 
	var total_regen := 0.0
	var total_armor := 0.0
	var total_damage := 0.0
	
	for comp in equipped_components:
		if not comp.is_active: continue
		total_hp += comp.hp
		total_speed += comp.speed
		total_jump += comp.dash_power 
		total_regen += comp.energy_regen 
		total_armor += comp.armor
		total_damage += comp.damage
		
	if health_component:
		var old_max = health_component.MAX_HEALTH
		var old_hp = health_component.health
		var ratio = old_hp / old_max if old_max > 0 else 1.0
		
		health_component.MAX_HEALTH = total_hp
		health_component.regen_rate = total_regen
		
		# Mantain HP percentage when max hp changes
		health_component.health = total_hp * ratio
		
		# Update UI
		_on_health_changed(health_component.health, health_component.MAX_HEALTH)
		
	if movement_component:
		movement_component.speed = total_speed
		movement_component.jump_height = total_jump
