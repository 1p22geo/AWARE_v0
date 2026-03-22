extends Node
class_name ProjectileController

@export var projectile_scene: PackedScene

func create_projectile(src: Vector3, dest: Vector3, damage: float = 25.0) -> void:
	if not projectile_scene:
		push_error("ProjectileController: projectile_scene not set")
		return
	
	var projectile = projectile_scene.instantiate() as Projectile
	if not projectile:
		push_error("ProjectileController: failed to instantiate projectile")
		return
	
	# Set damage before adding to scene
	projectile.damage = damage
	
	# Add to root scene so projectiles persist independently of player
	get_tree().current_scene.add_child(projectile)
	projectile.initialize(src, dest)
