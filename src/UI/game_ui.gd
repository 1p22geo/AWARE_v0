extends Control

signal components_updated(equipped_components: Array[ComponentData])
signal graph_updated(nodes: Dictionary, connections: Array)

@onready var health_bar: ProgressBar = %HealthBar
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var overheat_container: HBoxContainer = %OverheatContainer
@onready var screen_clipper: Control = %ScreenClipper
@onready var screens_container: VBoxContainer = %ScreensContainer
@onready var component_graph: ComponentGraphUI = find_child("ComponentGraph", true, false)
@onready var inventory_grid: GridContainer = find_child("InventoryGrid", true, false)

@onready var codex_list: ItemList = find_child("CodexList", true, false)
@onready var codex_name: Label = find_child("CodexName", true, false)
@onready var codex_desc: Label = find_child("CodexDesc", true, false)
@onready var codex_stats: Label = find_child("CodexStats", true, false)

# Labels for total bonuses
@onready var l_hp: Label = find_child("V_HP", true, false)
@onready var l_armor: Label = find_child("V_Armor", true, false)
@onready var l_speed: Label = find_child("V_Speed", true, false)
@onready var l_damage: Label = find_child("V_Damage", true, false)
@onready var l_power_limit: Label = find_child("V_PowerLimit", true, false)
@onready var l_power_limit_small: Label = find_child("L_PowerLimit", true, false)
@onready var l_synergies: Label = find_child("L_Synergies", true, false)
@onready var synergies_list: VBoxContainer = find_child("SynergiesList", true, false)

@onready var death_screen: CanvasLayer = find_child("DeathScreen", true, false)

var current_screen := 0
const TOTAL_SCREENS := 4
const ANIM_DURATION := 0.35
var is_animating := false

var codex_components: Array[ComponentData] = []

func _ready() -> void:
	add_to_group("UI")
	_update_screen_sizes()
	screen_clipper.resized.connect(_update_screen_sizes)

	if component_graph:
		component_graph.graph_updated.connect(_on_graph_updated)

	_populate_inventory_defaults.call_deferred()
	_init_codex.call_deferred()

	_connect_to_player_death.call_deferred()

func _populate_inventory_defaults() -> void:
	if inventory_grid == null:
		return
	var default_paths := [
		"res://scenes/components/core_health.tres",
		"res://scenes/components/attack_component.tres",
		"res://scenes/components/speed_module.tres",
		"res://scenes/components/jump_component.tres",
		"res://scenes/components/regen_module.tres",
		"res://scenes/components/armor_module.tres",
	]
	var slots := []
	for child in inventory_grid.get_children():
		if child.has_method("set_component"):
			slots.append(child)
	for i in range(min(slots.size(), default_paths.size())):
		var res := load(default_paths[i])
		if res is ComponentData:
			slots[i].set_component(res)

func _init_codex() -> void:
	if codex_list == null:
		return
	if not codex_list.item_selected.is_connected(_on_codex_selected):
		codex_list.item_selected.connect(_on_codex_selected)
	_load_codex_components()
	_refresh_codex_list()
	if codex_components.size() > 0:
		codex_list.select(0)
		_show_codex_component(codex_components[0])

func _load_codex_components() -> void:
	codex_components.clear()
	var dir := DirAccess.open("res://scenes/components")
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue
		if not file_name.ends_with(".tres"):
			continue
		var path := "res://scenes/components/" + file_name
		var res := load(path)
		if res is ComponentData:
			codex_components.append(res)
	dir.list_dir_end()
	# Stable order
	codex_components.sort_custom(func(a: ComponentData, b: ComponentData) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0
	)

func _refresh_codex_list() -> void:
	if codex_list == null:
		return
	codex_list.clear()
	for c in codex_components:
		codex_list.add_item(c.name)

func _on_codex_selected(index: int) -> void:
	if index < 0 or index >= codex_components.size():
		return
	_show_codex_component(codex_components[index])

func _show_codex_component(c: ComponentData) -> void:
	if codex_name:
		codex_name.text = c.name
	if codex_desc:
		codex_desc.text = c.description
	if codex_stats:
		codex_stats.text = _format_component_stats(c)

func _format_component_stats(c: ComponentData) -> String:
	var lines: Array[String] = []
	lines.append("Power Cost: " + str(c.power_cost))
	lines.append("")
	lines.append("HP: " + str(c.hp))
	lines.append("Armor: " + str(c.armor))
	lines.append("Speed: " + str(c.speed))
	lines.append("Dash Power: " + str(c.dash_power))
	lines.append("Dash Cooldown: " + str(c.dash_cooldown))
	lines.append("Jump Count: " + str(c.jump_count))
	lines.append("")
	lines.append("Damage: " + str(c.damage))
	lines.append("Attack Speed: " + str(c.attack_speed))
	lines.append("Attack Range: " + str(c.attack_range))
	lines.append("")
	lines.append("Energy Storage: " + str(c.energy_storage))
	lines.append("Energy Regen: " + str(c.energy_regen))
	lines.append("")
	lines.append("Overheat: " + str(c.overheat))
	lines.append("Overheat Limit: " + str(c.overheat_limit))
	return "\n".join(lines)

func _connect_to_player_death() -> void:
	# Find player via the game world SubViewport
	var world = find_child("World", true, false)
	if world:
		var player = world.find_child("Player", true, false)
		if player:
			var health = player.find_child("HealthComponent", true, false)
			if health and health.has_signal("die"):
				health.die.connect(_on_player_death)

func _on_player_death() -> void:
	if death_screen:
		death_screen.show_death()
		if not death_screen.restart_requested.is_connected(_on_restart_requested):
			death_screen.restart_requested.connect(_on_restart_requested)

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()

func _on_graph_updated(nodes: Dictionary, connections: Array) -> void:
	graph_updated.emit(nodes, connections)

func get_graph_data() -> Dictionary:
	if component_graph:
		return component_graph.get_graph_data()
	return { "nodes": {}, "connections": [] }

func update_total_bonuses(stats: Dictionary) -> void:
	if l_hp: l_hp.text = str(snapped(stats.hp, 0.1))
	if l_armor: 
		l_armor.text = str(snapped(stats.armor, 0.1))
		var l_armor_small = find_child("L_Armor", true, false)
		if l_armor_small: l_armor_small.text = "Armor: " + l_armor.text
		
	if l_speed: 
		l_speed.text = str(snapped(stats.speed, 0.1))
		var l_speed_small = find_child("L_Speed", true, false)
		if l_speed_small: l_speed_small.text = "Speed: " + l_speed.text
		
	if l_damage: l_damage.text = str(snapped(stats.damage, 0.1))
	
	var power_text = str(snapped(stats.power_cost, 0.1)) + " / " + str(stats.max_power)
	if l_power_limit: l_power_limit.text = power_text
	if l_power_limit_small: l_power_limit_small.text = "Power: " + power_text
	
	if l_synergies:
		if stats.has("synergies") and stats.synergies.size() > 0:
			var names = []
			for s in stats.synergies: names.append(s.name)
			l_synergies.text = "Active Synergies: " + ", ".join(names)
		else:
			l_synergies.text = "Active Synergies: None"
			
	if synergies_list:
		for child in synergies_list.get_children():
			child.queue_free()
		
		if stats.has("synergies"):
			for s in stats.synergies:
				var label = Label.new()
				label.text = ">> " + s.name + " (Cost: " + str(s.power) + ")"
				label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
				synergies_list.add_child(label)
				
				var details = Label.new()
				var bonus_str = ""
				if s.hp != 0: bonus_str += " HP:+" + str(s.hp)
				if s.speed != 0: bonus_str += " Speed:+" + str(s.speed)
				if s.damage != 0: bonus_str += " Damage:+" + str(s.damage)
				details.text = "    " + bonus_str
				details.add_theme_font_size_override("font_size", 12)
				synergies_list.add_child(details)

	if component_graph and stats.has("synergized_connections"):
		component_graph.highlight_connections(stats.synergized_connections)
	
	if stats.power_cost > stats.max_power:
		if l_power_limit: l_power_limit.add_theme_color_override("font_color", Color.RED)
	else:
		if l_power_limit: l_power_limit.remove_theme_color_override("font_color")

func _update_screen_sizes() -> void:
	var h := screen_clipper.size.y
	var w := screen_clipper.size.x
	screens_container.size.x = w
	for child in screens_container.get_children():
		if child is Control:
			child.custom_minimum_size.y = h
	screens_container.position.y = -current_screen * h

func _input(event: InputEvent) -> void:
	# Minimal debug - print when attack action fires
	if event.is_action("attack") and event.is_pressed():
		print("GameUI: attack action fired")
		_handle_attack()

	if is_animating:
		return

	if event.is_action_pressed("inventory"):
		if current_screen == 1:
			_go_to_screen(0)
		else:
			_go_to_screen(1)
		get_viewport().set_input_as_handled()
		return

	# Prevent scroll switching screen if mouse is over GraphEdit
	if component_graph and component_graph.get_global_rect().has_point(get_global_mouse_position()) and current_screen == 1:
		return

	# Sprawdzamy przewijanie w dół (następny ekran)
	var is_scroll_down = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN
	var is_ui_down := event.is_action_pressed("ui_down")

	if is_scroll_down or is_ui_down:
		if current_screen < TOTAL_SCREENS - 1:
			_go_to_screen(current_screen + 1)
			get_viewport().set_input_as_handled()
		return

	# Sprawdzamy przewijanie w górę (poprzedni ekran)
	var is_scroll_up = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP
	var is_ui_up := event.is_action_pressed("ui_up")

	if is_scroll_up or is_ui_up:
		if current_screen > 0:
			_go_to_screen(current_screen - 1)
			get_viewport().set_input_as_handled()

func _handle_attack() -> void:
	var world = find_child("World", true, false)
	if not world:
		return
	var player = world.find_child("Player", true, false)
	if not player:
		return
	var player_controller = player.find_child("PlayerController", true, false)
	if player_controller and player_controller.has_method("attack"):
		player_controller.attack()

func _go_to_screen(index: int) -> void:
	current_screen = index
	
	is_animating = true
	var target_y := -current_screen * screen_clipper.size.y
	var tween := create_tween()
	# Ensure UI transition still plays while the game is paused.
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(screens_container, "position:y", target_y, ANIM_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): is_animating = false)
	get_tree().paused = current_screen != 0

func update_health(current_hp: float, max_hp: float) -> void:
	if not health_bar: return
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func update_energy(current_energy: float, max_energy: float) -> void:
	if not energy_bar: return
	energy_bar.max_value = max_energy
	energy_bar.value = current_energy

func update_overheat(comp_name: String, current_heat: float, heat_limit: float) -> void:
	var existing: ProgressBar = null
	for child in overheat_container.get_children():
		if child.name == "OH_" + comp_name:
			existing = child as ProgressBar
			break
	if heat_limit <= 0.0:
		if existing:
			existing.queue_free()
		return
	if existing == null:
		existing = ProgressBar.new()
		existing.name = "OH_" + comp_name
		existing.custom_minimum_size = Vector2(60, 14)
		existing.show_percentage = false
		existing.rounded = true
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color(0.15, 0.15, 0.15, 1)
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.9, 0.5, 0.1, 1)
		existing.add_theme_stylebox_override("background", bg)
		existing.add_theme_stylebox_override("fill", fill)
		overheat_container.add_child(existing)
	existing.max_value = heat_limit
	existing.value = current_heat
