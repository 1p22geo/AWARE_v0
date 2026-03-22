extends Area3D

var _door_mesh: MeshInstance3D
var _time := 0.0
var _active := false
var _triggered := false

# --- lifecycle ---

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_door_mesh = get_node_or_null("DoorMesh")

	# Hide door until components are collected
	if _door_mesh:
		_door_mesh.visible = false
	monitoring = false

	GameState.component_collected.connect(_on_component_collected)

func _process(delta: float) -> void:
	if not _active or _door_mesh == null or _door_mesh.material_override == null:
		return
	_time += delta
	var pulse := (sin(_time * 2.5) + 1.0) / 2.0
	var energy: float = lerp(2.0, 5.0, pulse)
	_door_mesh.material_override.emission_energy_multiplier = energy
	var alpha: float = lerp(0.5, 0.85, pulse)
	_door_mesh.material_override.albedo_color.a = alpha

# --- door reveal ---

func _on_component_collected(_total: int) -> void:
	if _active:
		return
	if not GameState.has_enough_components():
		return
	_reveal_door()

func _reveal_door() -> void:
	_active = true
	monitoring = true
	if _door_mesh == null:
		return

	_door_mesh.visible = true
	if _door_mesh.material_override:
		_door_mesh.material_override.albedo_color.a = 0.0
		_door_mesh.material_override.emission_energy_multiplier = 10.0

	var t := create_tween()
	if _door_mesh.material_override:
		t.tween_property(_door_mesh.material_override, "albedo_color:a", 0.7, 1.2).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(_door_mesh.material_override, "emission_energy_multiplier", 3.0, 1.5)

# --- player enters door ---

func _on_body_entered(body: Node3D) -> void:
	if _triggered:
		return
	if not body.is_in_group("Player"):
		return
	if not GameState.has_enough_components():
		return
	_triggered = true
	GameState.complete_level()
