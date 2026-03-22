extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if not GameState.has_enough_components():
		print("[LevelExitZone] Not enough components: %d / %d" % [GameState.collected_components, GameState.REQUIRED_COMPONENTS])
		return
	GameState.complete_level()
