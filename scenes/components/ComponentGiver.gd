extends Area3D

@export var component_resource: Resource

func _on_body_entered(body):
    print("Body entered ComponentGiver: ", body.name, " group: ", body.get_groups())
	if body.is_in_group("player"):
		print("Player entered ComponentGiver!")
		var player = body
		if player.has_method("acquire_component"):
			print("Player has acquire_component method. Acquiring component...")
			player.acquire_component(component_resource)
			queue_free()
		else:
			print("Player DOES NOT have acquire_component method.")
	else:
		print("Body is not player.")
