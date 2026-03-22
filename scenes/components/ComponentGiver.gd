extends Area3D

@export var component_resource: Resource

func _on_body_entered(body):
	if body.is_in_group("player"):
		var player = body
		if player.has_method("acquire_component"):
			player.acquire_component(component_resource)
			queue_free()
