extends State
class_name followState

@onready var movement_component: MovementComponent = get_parent().get_parent().get_parent().get_node("MovementComponent") as MovementComponent

@export var speed: float = 1.5
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 1.0
@export var damage: float = 10.0

var enemy : CharacterBody3D
var player : CharacterBody3D
var attack_timer: float = 0.0

func Enter():
	enemy = get_parent().get_parent().get_parent() as CharacterBody3D
	var player_group = get_tree().get_first_node_in_group("Player")
	if player_group:
		player = player_group.get_node("Player") as CharacterBody3D

	if not movement_component:
		return
	movement_component.speed = speed
	attack_timer = 0.0


func Update(_delta: float):
	if not player or not is_instance_valid(player) or not movement_component:
		Change.emit(self, "wanderState")
		return

	var dist = enemy.global_position.distance_to(player.global_position)

	# Sprawdź czy gracz jest nadal widoczny
	if dist > 15.0:
		Change.emit(self, "wanderState")
		return

	# Attack if in range
	if dist <= attack_range:
		attack_timer += _delta
		if attack_timer >= attack_cooldown:
			attack_player()
			attack_timer = 0.0
		movement_component.move_direction = Vector3.ZERO
	else:
		attack_timer = 0.0
		var direction = (player.global_position - enemy.global_position).normalized()
		movement_component.move_direction = direction

func attack_player() -> void:
	if not player:
		return
	var health = player.get_node_or_null("HealthComponent") as Node
	var armor = 0.0
	var player_comp_mgr = player.get_node_or_null("ComponentManager")
	if player_comp_mgr and player_comp_mgr.has_method("get_total_armor"):
		armor = player_comp_mgr.get_total_armor()
	if health and health.has_method("take_damage"):
		health.take_damage(damage, armor)

func Physics_Update(_delta: float):
	if not movement_component or not enemy:
		return
	movement_component.move(enemy, _delta)
