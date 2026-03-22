extends Control

@onready var label = $Label
var tween: Tween

func show_notification(text: String, duration: float = 3.0):
	print("NotificationUI: Showing notification for: ", text)
	label.text = text
	self.visible = true # Ensure the Control node is visible
	
	if tween and tween.is_running():
		tween.kill()
		
	tween = get_tree().create_tween()
	
	# Fade in
	tween.tween_property(self, "modulate.a", 1.0, 0.5)
	# Wait
	tween.tween_interval(duration)
	# Fade out
	tween.tween_property(self, "modulate.a", 0.0, 0.5)
	tween.tween_callback(func(): self.visible = false) # Hide after fading out

func _ready():
	modulate.a = 0.0
	self.visible = false # Start invisible
