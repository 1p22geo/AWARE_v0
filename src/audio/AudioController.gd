extends Node

var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0
var environment_volume: float = 1.0

func _ready() -> void:
	print("AudioController _ready: Master Volume = ", master_volume)

func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	# Here you would typically update the AudioServer bus volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	print("Master volume set to: ", master_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
	print("SFX volume set to: ", sfx_volume)

func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BackgroundMusic"), linear_to_db(music_volume))
	print("Music volume set to: ", music_volume)
	
func set_environment_volume(volume: float) -> void:
	environment_volume = clampf(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Environment"), linear_to_db(environment_volume))
	print("Environment volume set to: ", environment_volume)

func play_sfx(sfx_path: String) -> void:
	# Placeholder for playing a sound effect
	print("Playing SFX: ", sfx_path, " at volume ", sfx_volume)

func play_music(music_path: String) -> void:
	# Placeholder for playing music
	print("Playing Music: ", music_path, " at volume ", music_volume)
