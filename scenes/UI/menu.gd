extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options


func pause()-> void:
	var is_paused = not get_tree().paused
	visible = is_paused
	get_tree().paused = is_paused

func _ready() -> void:
	visible = false
	main_buttons.visible = true
	options.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()




func _on_return_from_options() -> void:
	options.visible = false
	main_buttons.visible = true
	
	

func _on_resume() -> void:
	pause()

func _on_options() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit() -> void:
	get_tree().quit()
