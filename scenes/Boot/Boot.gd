extends Control

@export var skip_boot_scene: bool = false
@export var Title: Control
const MAIN_MENU_SCENE = "res://scenes/UI/MainMenu/MainMenu.tscn"


func _ready() -> void:
	AudioController.set_master_volume(0.8)
	AudioController.set_sfx_volume(0.8)
	AudioController.set_environment_volume(0.67)
	

	if skip_boot_scene and OS.is_debug_build():
		get_tree().change_scene_to_file.call_deferred(MAIN_MENU_SCENE)
		return

	$Timer.start()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_timer_2_timeout() -> void:
	Title.visible = true
