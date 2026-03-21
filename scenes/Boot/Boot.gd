extends Control

@export var skip_boot_scene: bool = false
@export var Title: Control
const MAIN_MENU_SCENE = "res://scenes/UI/MainMenu/MainMenu.tscn"


func _ready() -> void:
	# Access the AudioController singleton and interact with it
	print("--- Boot.gd interacting with AudioController ---")
	print("Initial Master Volume from Boot.gd: ", AudioController.master_volume)
	print("Initial SFX Volume from Boot.gd: ", AudioController.sfx_volume)

	AudioController.set_master_volume(0.5)
	AudioController.set_sfx_volume(0.8)
	AudioController.play_sfx("res://assets/AUDIO/sfx/lick_tenor_sax.mp3")

	print("New Master Volume from Boot.gd: ", AudioController.master_volume)
	print("New SFX Volume from Boot.gd: ", AudioController.sfx_volume)
	print("--- End Boot.gd interaction ---")

	if skip_boot_scene and OS.is_debug_build():
		get_tree().change_scene_to_file.call_deferred(MAIN_MENU_SCENE)
		return

	$Timer.start()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_timer_2_timeout() -> void:
	Title.visible = true
