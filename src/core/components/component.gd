extends Resource
class_name ComponentData

@export var name: String = "Component"
@export var icon: Texture2D

# Component HP
@export var hp: float = 50.0
var current_hp: float = 50.0

# Energy
@export var energy_storage: float = 0.0
@export var energy_regen: float = 0.0

# Defense
@export var armor: float = 0.0

# Movement
@export var speed: float = 0.0
@export var dash_power: float = 0.0
@export var dash_cooldown: float = 0.0
@export var jump_count: int = 0

# Offense
@export var damage: float = 0.0
@export var attack_speed: float = 0.0
@export var attack_range: float = 0.0

# Overheat
@export var overheat: float = 0.0
@export var overheat_limit: float = 0.0

# Power cost
@export var power_cost: float = 1.0

var is_active: bool = true
var current_overheat: float = 0.0

func _init() -> void:
	current_hp = hp

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0.0:
		current_hp = 0.0
		is_active = false

func repair(amount: float) -> void:
	current_hp = minf(current_hp + amount, hp)
	if current_hp > 0.0:
		is_active = true

func add_overheat(amount: float) -> void:
	current_overheat += amount
	if current_overheat >= overheat_limit and overheat_limit > 0.0:
		is_active = false

func cool_down(amount: float) -> void:
	current_overheat = maxf(current_overheat - amount, 0.0)
	if current_overheat < overheat_limit and current_hp > 0.0:
		is_active = true
