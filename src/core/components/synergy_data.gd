extends Resource
class_name SynergyData

@export var name: String = "Synergy"
@export var description: String = ""

# Component names that trigger this synergy
@export var component_a: String
@export var component_b: String

# Bonuses
@export var hp_bonus: float = 0.0
@export var speed_bonus: float = 0.0
@export var armor_bonus: float = 0.0
@export var damage_bonus: float = 0.0
@export var energy_regen_bonus: float = 0.0
@export var dash_power_bonus: float = 0.0
@export var jump_count_bonus: int = 0
@export var jump_disabled: bool = false

# Multipliers
@export var hp_mult: float = 1.0
@export var speed_mult: float = 1.0
@export var armor_mult: float = 1.0
@export var damage_mult: float = 1.0

# Power cost adjustment for the link itself
@export var link_power_cost: float = 2.0
