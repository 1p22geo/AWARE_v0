extends Node
class_name EnemyContoller

@onready var body: CharacterBody3D = get_parent()
@onready var health_component: HealthComponent = $"../HealthComponent"

func _ready() -> void:
	if health_component:
		health_component.die.connect(_on_die)

func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)

func _on_die() -> void:
	body.queue_free()
