extends Node
class_name HealthComponent

@export var MAX_HEALTH := 100.0

signal die
signal health_change

var health := MAX_HEALTH

func take_damage(amount):
	health -= amount
	if health <= 0:
		die.emit()
	health_change.emit(health)

func heal(amount):
	if health < MAX_HEALTH:
		health += amount;
		if health > MAX_HEALTH:
			health = MAX_HEALTH
		health_change.emit(health)
