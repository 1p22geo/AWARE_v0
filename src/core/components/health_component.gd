extends Node
class_name HealthComponent

@export var MAX_HEALTH := 100.0
@export var regen_rate := 0.0 # Per second

signal die
signal health_change(hp: float, max_hp: float)

@onready var health := MAX_HEALTH

func _ready() -> void:
	call_deferred("_emit_initial")

func _emit_initial():
	health_change.emit(health, MAX_HEALTH)

func _process(delta: float) -> void:
	if regen_rate > 0.0 and health < MAX_HEALTH:
		heal(regen_rate * delta)

func take_damage(amount):
	health -= amount
	if health <= 0:
		health = 0
		die.emit()
	health_change.emit(health, MAX_HEALTH)

func heal(amount):
	if health < MAX_HEALTH:
		health += amount
		if health > MAX_HEALTH:
			health = MAX_HEALTH
		health_change.emit(health, MAX_HEALTH)
