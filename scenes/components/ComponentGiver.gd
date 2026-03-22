extends Area3D

@export var component_resource: Resource

func _on_body_entered(body):
	print("Body entered ComponentGiver: ", body.name, " group: ", body.get_groups())
	if body.is_in_group("Player"):
		print("Player entered ComponentGiver!")
		var player_node = body # The CharacterBody3D node
		# Find the ComponentManager child node
		var component_manager = player_node.find_child("ComponentManager")
		
		if component_manager and component_manager.has_method("acquire_component"):
			print("ComponentManager found. Acquiring component...")
			component_manager.acquire_component(component_resource)
			queue_free()
		else:
			print("ComponentManager or acquire_component method not found on player's child.")
	else:
		print("Body is not player.")
