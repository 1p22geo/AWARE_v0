extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

@onready var master_slider: HSlider = %MasterSlider
@onready var master_value_label: Label = %MasterValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value_label: Label = %MusicValue
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value_label: Label = %SfxValue
@onready var environment_slider: HSlider = %EnvironmentSlider
@onready var environment_value_label: Label = %EnvironmentValue


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

func _init_volume_sliders() -> void:
	master_slider.value = AudioController.master_volume * 100
	_update_label(master_value_label, master_slider.value)
	
	music_slider.value = AudioController.music_volume * 100
	_update_label(music_value_label, music_slider.value)
	
	sfx_slider.value = AudioController.sfx_volume * 100
	_update_label(sfx_value_label, sfx_slider.value)
	
	environment_slider.value = AudioController.environment_volume * 100
	_update_label(environment_value_label, environment_slider.value)

func _update_label(label: Label, value: float) -> void:
	label.text = "%d%%" % value

func _on_master_slider_changed(value: float) -> void:
	_update_label(master_value_label, value)
	AudioController.set_master_volume(value / 100.0)

func _on_music_slider_changed(value: float) -> void:
	_update_label(music_value_label, value)
	AudioController.set_music_volume(value / 100.0)

func _on_sfx_slider_changed(value: float) -> void:
	_update_label(sfx_value_label, value)
	AudioController.set_sfx_volume(value / 100.0)

func _on_environment_slider_changed(value: float) -> void:
	_update_label(environment_value_label, value)
	AudioController.set_environment_volume(value / 100.0)

func _on_return_from_options() -> void:
	options.visible = false
	main_buttons.visible = true
	
func _on_resume() -> void:
	pause()

func _on_options() -> void:
	main_buttons.visible = false
	options.visible = true
	_init_volume_sliders()

func _on_exit() -> void:
	get_tree().quit()
