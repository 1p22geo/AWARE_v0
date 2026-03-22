extends Control

@onready var label = $Label
var tween: Tween

func show_notification(text: String, duration: float = 3.0):
	label.text = text
	
	if tween and tween.is_running():
		tween.kill()
		
	tween = get_tree().create_tween()
	
	# Fade in
	tween.tween_property(self, "modulate.a", 1.0, 0.5)
	# Wait
	tween.tween_interval(duration)
	# Fade out
	tween.tween_property(self, "modulate.a", 0.0, 0.5)

func _ready():
	modulate.a = 0.0
