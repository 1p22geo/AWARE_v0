extends Control

@export var skip_boot_scene: bool = false

const MAIN_MENU_SCENE = "res://scenes/UI/MainMenu/MainMenu.tscn"


func _ready() -> void:
	if skip_boot_scene and OS.is_debug_build():
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
		return

	$Timer.start()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
